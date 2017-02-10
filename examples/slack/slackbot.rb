require 'dotenv'
Dotenv.load
require 'slack-ruby-bot'
require 'wordhop'
require 'json'

# Wordhop Api Key
Wordhop.apikey = ENV['WORDHOP_API_KEY']
# Unique Wordhop Client Key for your bot
Wordhop.clientkey = ENV['WORDHOP_CLIENT_KEY']
# possible values: "messenger" or "slack"
Wordhop.platform = "slack"

class Bot < SlackRubyBot::Bot
    
    
    # Handle forwarding the messages sent by a human through your bot
    Wordhop.on :'chat response' do |data|
        client = self.instance.hooks.client
        text = data['text']
        channel = data['channel']
        client.say({'text': text, 'channel': channel})
    end

    Wordhop.on :'channel update' do |data|
    end

    command 'hi' do |client, data, _match|
        body = JSON.parse(data.to_json)
        hopInResponse = Wordhop.hopIn(body)
        # If your bot is paused, stop it from replying
        if hopInResponse['paused'] != true
            text = 'Hello there.'
            outgoingMessage = {channel: data.channel, text: text}
            Wordhop.hopOut(outgoingMessage)
            client.say(text: text, channel: data.channel)
        end
    end

    command 'help' do |client, data, _match|
        body = JSON.parse(data.to_json)
        hopInResponse = Wordhop.hopIn(body)
        # let the user know that they are being routed to a human
        if hopInResponse['paused'] != true
            text = 'Hang tight. Let me see what I can do.'
            outgoingMessage = {channel: data.channel, text: text}
            Wordhop.hopOut(outgoingMessage)
            client.say(text: text, channel: data.channel)
            # send a Wordhop alert to your slack channel
            # that the user could use assistance
            Wordhop.assistanceRequested(body);
        end
    end

    match(/^(?<bot>\S*)[\s]*(?<expression>.*)$/) do |client, data, match|
        body = JSON.parse(data.to_json)
        hopInResponse = Wordhop.hopIn(body)
        if hopInResponse['paused'] != true
            # let the user know that the bot does not understand
            text = 'Huh?'
            outgoingMessage = {channel: data.channel, text: text}
            Wordhop.hopOut(outgoingMessage)
            client.say(text: text, channel: data.channel)
            # capture conversational dead-ends.
            Wordhop.logUnknownIntent(body);
        end
    end

end

SlackRubyBot::Client.logger.level = Logger::WARN

Bot.run
