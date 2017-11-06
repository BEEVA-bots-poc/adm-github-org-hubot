repo = "BEEVA-bots-poc/access"

module.exports = (robot) ->
  github = require('githubot')(robot)

  robot.respond /listar issues/i, (msg) ->
    github.get "https://api.github.com/repos/#{repo}/issues", {}, (issues) ->
      issues = issues.sort (a,b) -> a.number > b.number
      texts = ["https://github.com/#{repo}/issues"]
      for i in issues
        texts.push "[#{i.number}] #{i.title} realizada por #{i.user.login} con el contenido #{i.body}"
      text = texts.join '\n'
      msg.reply "Your issues\n#{text}"

  robot.respond /Quiero ver la número (.*)/i, (msg) ->
    numberIssue = msg.match[1]
    github.get "https://api.github.com/repos/#{repo}/issues/#{numberIssue}", {}, (issue) ->
      msg.reply "[#{issue.number}] #{issue.title} realizada por #{issue.user.login} con el contenido #{issue.body}\n¿Que deseas hacer con esta issue?\n1. Aceptar issue\n2. Responder issue\n3. Declinar issue\n"

  robot.respond /Quiero (.*) issue número (.*)/i, (res) ->
    respondUser = res.match[1]
    numberIssue = res.match[2]
    if respondUser is "Aceptar"
      res.reply "Vamos a aceptar issue #{numberIssue}"
    else if respondUser is "Responder"
      res.reply "Vamos a Responder issue #{numberIssue}"
    else
      github.put "https://api.github.com/repos/#{repo}/issues/#{numberIssue}/lock", {state: "closed"}, (issue, error) ->
       if error then console.log error
       text = "OK. he bloqueado la issue #{numberIssue}"
       msg.reply text
