# [Wordhop](https://www.wordhop.io) Slack Bot Ruby Example

This is a simple Slack bot with Wordhop integration example based on [slack-ruby-bot](https://github.com/dblock/slack-ruby-bot)

### Sign Up With Wordhop

You'll need an API key from Wordhop, as well as a Client Key for each Chatbot.  You can get both of those (free) when you add [Wordhop for Slack](https://slack.com/oauth/authorize?scope=users:read,users:read.email,commands,chat:write:bot,channels:read,channels:write,bot&client_id=23850726983.39760486257) via through a conversation with the Wordhop bot. 

### Connecting Your Bot to Slack

To connect a bot to Slack, [get a Bot API token from the Slack integrations page](https://my.slack.com/services/new/bot).

### Installation

```bash
$ gem install slack-ruby-bot ; gem install wordhop
```

### Usage

Set your environmental variables for `WORDHOP_API_KEY`, `WORDHOP_CLIENT_KEY`, `SLACK_API_TOKEN`.

```bash
$ export WORDHOP_API_KEY=xxxxxxxxxxxxxxxxxxxx
$ export WORDHOP_CLIENT_KEY=xxxxxxxxxxxxxxxxxxxx
$ export SLACK_API_TOKEN=xxxxx-xxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxx
```

Run the following command to get your bot online:

```bash
$ ruby slackbot.rb
```
