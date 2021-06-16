require 'singleton'
require 'discordrb'

class PMBot
  include Singleton

  def initialize
    @bot = Discordrb::Commands::CommandBot.new token: ENV.fetch('BOT_TOKEN', ''), prefix: '!'
    init_functions
  end

  def run
    @bot.run(true)
  end

  private

  def init_functions
    send_user_name
  end

  def send_user_name
    @bot.command :user do |event|
      event.user.name
    end
  end

end