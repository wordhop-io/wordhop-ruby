require 'facebook/messenger'
require 'rubygems'
require '../../wordhop'

include Facebook::Messenger
include Wordhop



Wordhop.on :'chat response' do |data|
    Bot.deliver(data, access_token: ENV['ACCESS_TOKEN'])
end

def sendMessage(message, data)
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

  if hopInResponse['paused'] != true
      
      case message.text
      when /hello/i
        sendMessage(message,
          text: 'Hello, human!',
          quick_replies: [
            {
              content_type: 'text',
              title: 'Hello, bot!',
              payload: 'HELLO_BOT'
            }
          ]
        )
        puts message.inspect
      when /something humans like/i
        sendMessage(message,
          text: 'I found something humans seem to like:'
        )
        
        sendMessage(message,
          attachment: {
            type: 'image',
            payload: {
              url: 'https://i.imgur.com/iMKrDQc.gif'
            }
          }
        )

        sendMessage(message,
          attachment: {
            type: 'template',
            payload: {
              template_type: 'button',
              text: 'Did human like it?',
              buttons: [
                { type: 'postback', title: 'Yes', payload: 'HUMAN_LIKED' },
                { type: 'postback', title: 'No', payload: 'HUMAN_DISLIKED' }
              ]
            }
          }
        )
        Wordhop.assistanceRequested(message.messaging)

      else
        sendMessage(message,
          text: 'You are now marked for extermination.'
        )

        sendMessage(message,
          text: 'Have a nice day.'
        )
        Wordhop.logUnknownIntent(message.messaging)

      end
    end
end


Bot.on :postback do |postback|
  case postback.payload
  when 'HUMAN_LIKED'
    text = 'That makes bot happy!'
  when 'HUMAN_DISLIKED'
    text = 'Oh.'
  end

  sendMessage(postback,
    text: text
  )
end

Bot.on :delivery do |delivery|
  puts "Delivered message(s) #{delivery.ids}"
end
