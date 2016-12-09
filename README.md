# [Wordhop](https://www.wordhop.io) - Monitor and Optimize Your Conversational Experience
## For Chatbots Built in Python

With Wordhop you can sync up your Python-based Chatbot to Slack, so you can retain your users without ever leaving Slack.  Wordhop monitors your Chatbot for friction in your conversational experience and alerts you on Slack in real-time. Simply add Wordhop to Slack and then drop in a couple of lines of code into your Chatbot.  Wordhop integrates in minutes, not days, and begins working immediately.  From Slack, you can pause and take over your bot, then hand the conversation back to your bot.  Actionable analytics also show you and your Slack team where you can optimize your conversational experience and measure results. 

### What you can do with Wordhop:
* [See Key Features](https://developer.wordhop.io)
* [Watch a Demo](https://www.youtube.com/watch?v=TAcwr3s9l4o)

### What you need to get started:
* [A Slack Account](http://www.slack.com)
* [Wordhop for Slack](https://slack.com/oauth/authorize?scope=users:read,users:read.email,commands,chat:write:bot,channels:read,channels:write,bot&client_id=23850726983.39760486257)
* [A Chatbot built in Ruby](https://github.com/hyperoslo/facebook-messenger)

### Installation

```bash
$ gem install facebook-messenger
```


### Usage

```ruby
require 'wordhop'

# Wordhop Api Key
Wordhop.apikey = ENV['WORDHOP_API_KEY']
# Unique Wordhop Client Key for your bot
Wordhop.clientkey = ENV['WORDHOP_CLIENT_KEY']
# possible values: "messenger" or "slack"
Wordhop.platform = "messenger" 
# Page Access Token (only required for Messenger bots)
Wordhop.token = ENV['ACCESS_TOKEN']
```

##### Tracking received messages:

When Messenger calls your receiving webhook, you'll need to log the data with Wordhop. 
__Note__: Wordhop can pause your bot so that it doesn't auto response while a human has taken over. The server response from your `hopIn` request will pass the `paused` state. Use that to stop your bot from responding to an incoming message. Here is an example:

```ruby
hopInResponse = Wordhop.hopIn(message.messaging)
if hopInResponse['paused'] != true
# proceed to process incoming message
 ...
```

##### Tracking sent messages:

Each time your bot sends a message, make sure to log that with Wordhop in the request's callback. Here is an example:
```ruby
def sendIt(message, data)
    payload = {
        recipient: message.sender,
        message: data
    }
    message.reply(data)
    Wordhop.hopOut(payload)
end
```

##### Human Take Over:

To enable the ability to have a human take over your bot, add the following code:

```ruby
# Handle forwarding the messages sent by a human through your bot
Wordhop.on :'chat response' do |data|
    Bot.deliver(data, access_token: ENV['ACCESS_TOKEN'])  # <= example of bot sending message
end
```
##### Log Unknown Intents:

Find the spot in your code your bot processes incoming messages it does not understand. You may have some outgoing fallback message there (i.e. "Oops I didn't get that!"). Within that block of code, call to `wordhop.logUnkownIntent` to capture these conversational ‘dead-ends’. Here's an example:

```ruby
# let the user know that the bot does not understand
sendIt(message, text: 'Huh?')
# capture conversational dead-ends.
Wordhop.logUnknownIntent(message.messaging)
```
##### Dial 0 to Speak With a Live Human Being:

Wordhop can trigger alerts to suggest when a human should take over for your Chatbot. To enable this, create an intent such as when a customer explicitly requests live assistance, and then include the following line of code where your bot listens for this intent:

```ruby
# match an intent to talk to a real human
if text == 'help'
    # let the user know that they are being routed to a human
    sendIt(message, text: 'Hang tight. Let me see what I can do.')
    # send a Wordhop alert to your slack channel
    # that the user could use assistance
    Wordhop.assistanceRequested(message.messaging)
    ...
```

Go back to Slack and wait for alerts. That's it! 
[Be sure to check out our example.](examples/messenger/README.md)


### Looking for something we don't yet support?  
* [Join our mailing list and we'll notifiy you](https://www.wordhop.io/contact.html)
* [Contact Support](mailto:support@wordhop.io)
