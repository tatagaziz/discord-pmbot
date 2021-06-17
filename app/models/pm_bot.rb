require 'singleton'
require 'discordrb'

class PmBot
  include Singleton

  def initialize
    @bot = Discordrb::Commands::CommandBot.new token: ENV.fetch('BOT_TOKEN', 'ODUzODk0MDUzMjM3MjI3NTIx.YMcAzg.Sn4AbPXq8u-WefZBezTm0C6qGu4'), prefix: '!'
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
    send_user_name
  end

  def send_user_name
    @bot.command :user do |event|
      return event.user.name
    end
  end

end