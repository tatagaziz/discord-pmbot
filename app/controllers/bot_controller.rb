class BotController < ApplicationController
  def index
    if PmBot.instance.connected?
      @rendered_text = "Bot is already connected"
    else
      PmBot.instance.run
      @rendered_text = "Bot has successfully connected"
    end
  end

  def stop
    if PmBot.instance.connected?
      PmBot.instance.stop
      @rendered_text = 'bot has successfully stopped'
    else
      @rendered_text = 'bot is not connected'
    end
  end
end
