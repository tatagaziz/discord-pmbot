require 'singleton'
require 'discordrb'

class PmBot
  include Singleton

  def initialize
    @token = ENV.fetch('BOT_TOKEN', '')
    @bot = Discordrb::Commands::CommandBot.new token: @token, prefix: '!'
    init_functions
  end

  def run
    @bot.run(true)
  end

  def stop
    @bot.stop
  end

  def connected?
    @bot.connected?
  end

  private

  def init_functions
    # Register Server
    @bot.command :register_server, description: 'register this server into the system' do |event|
      server_owner?(event.server, event.user.id) do
        if Server.where(discord_server_id:event.server).exists?
          return 'Server is already registered'
        end
        new_server = Server.new( discord_server_id: event.server.id, name: event.server.name)
        return 'Server has been successfully registered' if new_server.save
        'Server registration failed'
      end
    end

    # Assign Leader
    @bot.command :assign_leader, min_args: 1, max_args: 1, description: 'assign user as leader', usage: '!assign_leader @username' do |event, mention |
      owner_request_validation(event.server, event.user.id) do
          discord_user_id = get_discord_user_id_by_mention(mention)
          server = get_server_by_discord_id(event.server.id)
          server_member = event.server.member(discord_user_id)
          if server_member
            new_project_leader = ProjectLeader.new(discord_user_id: server_member.id, server_id:server.id)

            return "#{event.user.username} has been assigned as project leader" if new_project_leader.save
            'Project leader assignment failed'
          else
            'Member not found'
          end
      end
    end

    # Unassign Leader
    @bot.command :unassign_leader, min_args: 1, max_args: 1, description: 'unassign user as leader', usage: '!unassign_leader @username' do |event, mention |
      owner_request_validation(event.server, event.user.id) do
        event.respond """ WARNING
        Removing a leader will destroy ALL PROJECTS created by that leader
        Are you sure you want to remove this leader? (Y/N)"""
        event.user.await! do |answer_event|
          if answer_event.message.content =~ /^[Yy]+/
            discord_leader_id = get_discord_user_id_by_mention(mention)
            leader = get_leader_by_discord_id(discord_leader_id, answer_event.server.id)
            if leader.destroy
              answer_event.respond "<@#{discord_leader_id}> has been removed from leader"
            else
              answer_event.respond "Removal failed"
            end
            true
          else
            answer_event.respond "Process canceled"
            true
          end
        end

      end
    end

    # Create Project
    @bot.command :create_project, min_args: 1, max_args: 2, description: 'create new project', usage: '!create_project <name> <description:optional>' do |event, project_name, description|
      leader_request_validation(event.server, event.user.id) do
        server = get_server_by_discord_id(event.server.id)
        leader = get_leader_by_discord_id(event.user.id, event.server.id)
        new_project = Project.new(project_leader_id:leader.id, server_id:server.id, name:project_name, description:description)

        return "Project successfully created, id: #{new_project.id}, name: #{project_name}" if new_project.save
        'Project creation failed'
      end
    end
  end

  def get_discord_user_id_by_mention(mention)
    if mention =~ /^<@!/
      return mention[3..-2]
    end
    mention[2..-2]
  end

  def owner_request_validation(discord_server, discord_user_id)
    server_owner?(discord_server, discord_user_id) do
      server_registered?(discord_server) do
        yield
      end
    end
  end

  def leader_request_validation(discord_server, discord_user_id)
    server_leader?(discord_server, discord_user_id) do
      server_registered?(discord_server) do
        yield
      end
    end
  end

  def server_leader?(discord_server, discord_user_id)
    server = Server.find_by(discord_server_id: discord_server)
    if ProjectLeader.find_by(discord_user_id: discord_user_id, server_id: server.id)
      yield
    else
      'Only server leader may use this command'
    end
  end

  def server_owner?(discord_server, discord_user_id)
    server_owner = discord_server.owner
    if server_owner.id == discord_user_id
      yield
    else
      'Only server owner may use this command'
    end
  end

  def server_registered?(discord_server)
    if Server.where(discord_server_id:discord_server).exists?
      yield
    else
      'Server is not yet registered'
    end
  end
end

def get_server_by_discord_id(discord_server_id)
  Server.find_by(discord_server_id:discord_server_id)
end

def get_leader_by_discord_id(discord_user_id, discord_server_id)
  server = get_server_by_discord_id(discord_server_id)
  ProjectLeader.find_by(discord_user_id:discord_user_id, server_id:server.id)
end