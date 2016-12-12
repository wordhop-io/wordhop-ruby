require 'dotenv'
Dotenv.load

require 'facebook/messenger'
require 'rubygems'
require 'wordhop'

include Facebook::Messenger


Wordhop.token = ENV['ACCESS_TOKEN']
Wordhop.clientkey = ENV['WORDHOP_CLIENT_KEY']
Wordhop.apikey = ENV['WORDHOP_API_KEY']
Wordhop.platform = "messenger"

Wordhop.on :'chat response' do |data|
    Bot.deliver(data, access_token: ENV['ACCESS_TOKEN'])
end

def sendIt(message, data)
    payload = {
        recipient: message.sender,
        message: data   
    }
    message.reply(data)
    Wordhop.hopOut(payload)
end

Bot.on :message do |message|
  puts "Received '#{message.inspect}' from #{message.sender}"
  
  hopInResponse = Wordhop.hopIn(message.messaging)
  # If your bot is paused, stop it from replying
  if hopInResponse['paused'] != true
      case message.text
      when /hello/i
        sendIt(message, text: 'Hello there.')
      when /help/i
        # let the user know that they are being routed to a human
        sendIt(message, text: 'Hang tight. Let me see what I can do.')
        # send a Wordhop alert to your slack channel
        # that the user could use assistance
        Wordhop.assistanceRequested(message.messaging)
      else
        # let the user know that the bot does not understand
        sendIt(message, text: 'Huh?')
        # capture conversational dead-ends.
        Wordhop.logUnknownIntent(message.messaging)
      end
    end
end
