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
      msg.reply "Tus issues son:\n#{text}"

  robot.respond /Quiero ver la número (.*)/i, (msg) ->
    numberIssue = msg.match[1]
    github.get "https://api.github.com/repos/#{repo}/issues/#{numberIssue}", {}, (issue) ->
      msg.reply "[#{issue.number}] #{issue.title} realizada por #{issue.user.login} con el contenido #{issue.body}\n¿Que deseas hacer con esta issue?\n1. Aceptar issue\n2. Responder issue\n3. Declinar issue\n"

  robot.respond /Quiero ver los usuarios del sistema/i, (msg) ->
    msg.http('https://raw.githubusercontent.com/BEEVA-bots-poc/access/master/CONTRIBUTORS.json').get() (err, httpRes, body) ->
     users = JSON.parse body
     for i, index in users.contributors
      msg.send "Usuario del sistema número #{index + 1}: #{i.name}"

  robot.respond /Quiero (.*) issue número (.*)/i, (res) ->
    respondUser = res.match[1]
    numberIssue = res.match[2]
    #console.log(new Buffer('{"contributors":[{"name":"Julian", "email":"julian.perez@beeva.com", "git":"beeva-julianperez"}]}').toString('base64'));
    if respondUser is "Aceptar"
      res.reply "Vamos a aceptar issue #{numberIssue}"
      param = {
       message: "my commit message",
       committer: {
        name: "Julian Perez",
        email: "julian.perez@beeva.com"
       },
       content: "eyJjb250cmlidXRvcnMiOlt7Im5hbWUiOiJKdWxpYW4iLCAiZW1haWwiOiJqdWxpYW4ucGVyZXpAYmVldmEuY29tIiwgImdpdCI6ImJlZXZhLWp1bGlhbnBlcmV6In1dfQ==",
       sha: "0d5a690c8fad5e605a6e8766295d9d459d65de42"
      }
      github.put "https://api.github.com/repos/#{repo}/contents/CONTRIBUTORS.json", param, (issue) ->
       res.send "Usuario Añadido =)"
    else if respondUser is "Responder"
      res.reply "Vamos a Responder issue #{numberIssue}"
    else
      github.patch "https://api.github.com/repos/#{repo}/issues/#{numberIssue}", {state: "closed"}, (issue, error) ->
       if error then console.log error
       text = "OK. He cerrado la issue #{numberIssue} al no cumplir los requisitos previos"
       res.reply text
