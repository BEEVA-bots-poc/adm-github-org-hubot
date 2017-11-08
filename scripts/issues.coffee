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
      msg.send "Tus issues son:\n#{text}"

  robot.respond /Quiero ver la número (.*)/i, (msg) ->
    numberIssue = msg.match[1]
    github.get "https://api.github.com/repos/#{repo}/issues/#{numberIssue}", {}, (issue) ->
      msg.send "[#{issue.number}] #{issue.title} realizada por #{issue.user.login} con el contenido #{issue.body}\n¿Que deseas hacer con esta issue?\n1. Aceptar issue\n2. Responder issue\n3. Declinar issue\n"

  robot.respond /Quiero ver los usuarios del sistema/i, (msg) ->
    github.get "https://api.github.com/repos/#{repo}/contents/CONTRIBUTORS.json", {}, (contributors) ->
     content = JSON.parse new Buffer(contributors.content, 'base64').toString()
     for i, index in  content.contributors
      msg.send "Usuario del sistema número #{index + 1}: #{i.name}"

  robot.respond /Quiero (.*) issue número (.*)/i, (res) ->
    respondUser = res.match[1]
    numberIssue = res.match[2]
    if respondUser is "Aceptar"
      github.get "https://api.github.com/repos/#{repo}/issues/#{numberIssue}", {}, (issue) ->
       messageToCommit = JSON.parse issue.body
       res.http('https://raw.githubusercontent.com/BEEVA-bots-poc/access/master/CONTRIBUTORS.json').get() (err, httpRes, body) ->
        users = JSON.parse body
        users.contributors.push (messageToCommit)
        github.get "https://api.github.com/repos/#{repo}/contents/CONTRIBUTORS.json", {}, (infoCommit) ->
         contentCommit = new Buffer(JSON.stringify users).toString('base64')
         param = {
          message: "Added new User to repo",
          content: contentCommit,
          sha: infoCommit.sha
         }
         github.put "https://api.github.com/repos/#{repo}/contents/CONTRIBUTORS.json", param, (issue) ->
          res.send "----- ACEPTANDO ISSUE ----"
          github.patch "https://api.github.com/repos/#{repo}/issues/#{numberIssue}", {state: "closed"}, (issue, error) ->
           res.send "OK. He aceptado la issue #{numberIssue} y he añadido el usuario al contributors"
    else if respondUser is "Responder"
      param = {
       body: "El formato de la issue tiene que ser tipo JSON para que podamos identificarla. Debe tener los campos de name, email y user, Gracias =)"
      }
      github.post "https://api.github.com/repos/#{repo}/issues/#{numberIssue}/comments", param, (issue, error) ->
       if error then console.log error
       res.send "Contestada la issue #{numberIssue} al no cumplir los requisitos previos"
    else
      github.patch "https://api.github.com/repos/#{repo}/issues/#{numberIssue}", {state: "closed"}, (issue, error) ->
       if error then console.log error
       res.send "OK. He cerrado la issue #{numberIssue} al no cumplir los requisitos previos"
