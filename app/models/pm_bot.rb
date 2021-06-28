require 'singleton'
require 'discordrb'

class PmBot
  class NotOwnerError < StandardError; end

  class ServerNotRegisteredError < StandardError; end

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
      validate_owner!(event)
      Server.create!(discord_server_id: event.server.id, name: event.server.name)
      'Server has been successfully registered'

    rescue NotOwnerError
      return "Only server owner may use this command"
    rescue ActiveRecord::RecordInvalid
      return 'Server registration failed'
    end

    # Assign Leader
    @bot.command :assign_leader, min_args: 1, max_args: 1, description: 'assign user as leader', usage: '!assign_leader @username' do |event, mention|
      validate_owner!(event)

      discord_user_id = get_discord_user_id_by_mention(mention)
      server = Server.find_by!(discord_server_id: event.server.id)
      server_member = event.server.member(discord_user_id)
      if server_member
        ProjectLeader.create!(discord_user_id: server_member.id, server_id: server.id)
        return "#{event.user.username} has been assigned as project leader"
      else
        return 'Member not found'
      end

    rescue NotOwnerError
      return "Only server owner may use this command"
    rescue ActiveRecord::RecordNotFound
      return "Server is unregistered"
    rescue ActiveRecord::RecordInvalid
      return "Project Leader assignment failed"
    end

    # Unassign Leader
    @bot.command :unassign_leader, min_args: 1, max_args: 1, description: 'unassign user as leader', usage: '!unassign_leader @username' do |event, mention|
      validate_owner!(event)

      event.respond "Removing a leader will destroy ALL PROJECTS created by that leader. Are you sure you want to remove this leader? (Y/N)"
      event.user.await! do |answer_event|
        if answer_event.message.content =~ /^[Yy]+/
          discord_leader_id = get_discord_user_id_by_mention(mention)
          server = Server.find_by!(discord_server_id: event.server.id)
          leader = ProjectLeader.find_by!(discord_user_id: discord_leader_id, server_id: server.id)
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
      rescue ActiveRecord::RecordNotFound => e
        if e.model == Server
          answer_event.respond 'Server is not registered'
        else
          answer_event.respond "Leader not found"
        end
        true
      end
      return

    rescue NotOwnerError
      return "Only server owner may use this command"
    end

    # Create Project
    @bot.command :create_project, min_args: 1, max_args: 2, description: 'create new project', usage: '!create_project <name> <description:optional>' do |event, project_name, description|
      #   validate_owner!(event)
      #   server = Server.find_by!(discord_server_id: event.server.id)
      #   leader = ProjectLeader.find_by!(discord_user_id: event.user.id, server_id: server.id)
      #   Project.create!(project_leader_id: leader.id, server_id: server.id, name: project_name, description: description)
      #
      # rescue ActiveRecord::RecordNotFound => e
      #   event.respond e.message
      # rescue ActiveRecord::RecordInvalid
      #   return "Project Leader assignment failed"
      "unused command"
    end

    # Create Task
    @bot.command :create_task, min_args: 2, max_args: 2, description: 'create new task for user', usage: '!create_task <@username> <task_description>' do |event, mention, description|
      leader = validate_leader!(event)
      discord_user_id = get_discord_user_id_by_mention(mention)
      Task.create!(name:"", status:Task::INCOMPLETE, description:description, assignee_discord_id:discord_user_id, project_leader_id:leader.id)
      "Task \"#{description}\" has been successfully assigned to #{mention}"
    rescue ActiveRecord::RecordNotFound => e
      if e.model == Server
        return "Server is not registered"
      else
        return "Leader not found"
      end
    rescue ActiveRecord::RecordInvalid
      return 'Task creation failed'
    end

    # View one's own tasks
    @bot.command :view_tasks, description: 'see own tasks', usage: '!view_tasks' do |event|
      invoker_discord_id = event.user.id
      tasks = Task.where(assignee_discord_id:invoker_discord_id)
      if !tasks.empty?
        tasks.each do |task|
          status = task.status == Task::FINISHED ? "FINISHED" : "UNFINISHED"
          event << "[ID:#{task.id} - #{status}]  #{task.description}"
        end
      else
        event << "No task is assigned to you"
      end
      return nil
    end

    # Finish a task
    @bot.command :finish_task, min_args: 1, max_args: 1, description: 'finish task by task id', usage: '!finish_task <task_id1>, <task_id2>, ... ' do |event, *args|
      invoker_discord_id = event.user.id
      tasks = Task.where(id:args.map(&:to_i), assignee_discord_id: invoker_discord_id, status:Task::UNFINISHED)
      if !tasks.empty?
        tasks.each do |task|
          task.update(status: Task::FINISHED)
          event << "Task [ID:#{task.id}] \"#{task.description}\" has been finished"
        end
      else
        event << "The task ID(s) specified are either not yours, doesn't exist, or is already completed"
      end
      return nil
    end
  end

  def get_discord_user_id_by_mention(mention)
    if mention =~ /^<@!/
      return mention[3..-2]
    end
    mention[2..-2]
  end

  def validate_leader!(event)
    server = Server.find_by!(discord_server_id: event.server.id)
    ProjectLeader.find_by!(discord_user_id: event.user.id, server_id: server.id)
  end

  def validate_owner!(event)
    return if event.server.owner.id == event.user.id
    raise NotOwnerError, "Only server owner may use this command"
  end

  def server_registered?(discord_server)
    if Server.where(discord_server_id: discord_server).exists?
      yield
    else
      'Server is not yet registered'
    end
  end
end
