repo  = "BEEVA-bots-poc"

module.exports = (robot) ->
  github = require('githubot')(robot)

  robot.respond /listar issues/i, (msg) ->
    github.get "https://api.github.com/repos/#{repo}/access/issues", {}, (issues) ->
      issues = issues.sort (a,b) -> a.number > b.number
      texts = ["https://github.com/#{repo}/access/issues"]
      for i in issues
        texts.push "[#{i.number}] #{i.title} realizada por #{i.user.login} con el contenido #{i.body}"
      text = texts.join '\n'
      msg.reply "Your issues\n#{text}"

  robot.respond /Quiero ver la número (.*)/i, (msg) ->
    numberIssue = msg.match[1]
    github.get "https://api.github.com/repos/#{repo}/access/issues/#{numberIssue}", {}, (issue) ->
      msg.reply "[#{issue.number}] #{issue.title} realizada por #{issue.user.login} con el contenido #{issue.body}"

  robot.respond /Quiero ver la número (.*)/i, (msg) ->
   numberIssue = msg.match[1]
   github.get "https://api.github.com/repos/#{repo}/access/issues/#{numberIssue}", {}, (issue) ->
    msg.reply "[#{issue.number}] #{issue.title} realizada por #{issue.user.login} con el contenido #{issue.body}"
    attachments = [
      {
          "text": "Choose a game to play",
          "fallback": "You are unable to choose a game",
          "callback_id": "wopr_game",
          "color": "#3AA3E3",
          "attachment_type": "default",
          "actions": [
              {
                  "name": "game",
                  "text": "Chess",
                  "type": "button",
                  "value": "chess"
              },
              {
                  "name": "game",
                  "text": "Falken's Maze",
                  "type": "button",
                  "value": "maze"
              },
              {
                  "name": "game",
                  "text": "Thermonuclear War",
                  "style": "danger",
                  "type": "button",
                  "value": "war",
                  "confirm": {
                      "title": "Are you sure?",
                      "text": "Wouldn't you prefer a good game of chess?",
                      "ok_text": "Yes",
                      "dismiss_text": "No"
                  }
              }
          ]
      }
    ]
    msg.robot.adapter.customMessage
      channel: msg.envelope.room
      username: msg.robot.name
      attachments: [attachments]
