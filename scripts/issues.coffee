# Description:
#   Allows Hubot to view/reply issues and add to organization
#
# Dependencies:
#   "githubot": "0.4.x"
#   "hubot-conversation": "^1.1.1"
#
# Configuration:
#   HUBOT_GITHUB_REPO
#     The `user/repository` that you want to connect to. example: github/hubot-scripts
#   HUBOT_GITHUB_USER
#     The `user` that you want to connect to. example: github
#   HUBOT_GITHUB_TOKEN
#     You can retrieve your github token via:
#       curl -i https://api.github.com/issues -d '{"scopes":["repo"]}' -u "yourusername"
#     Enter your Github password when prompted. When you get a response, look for the "token" value
#
# Commands:
#   hubot listar issues
#   hubot Quiero ver la número <number>
#   hubot Quiero ver los usuarios del sistema
#   hubot Quiero <option> issue número <number>
#
# Author: Julian Pérez Sampedro

endPointGitHub = "https://api.github.com/repos/BEEVA-bots-poc/access"

module.exports = (robot) ->
  github = require('githubot')(robot)
  conversation = require('hubot-conversation');

  #Initialize Conversation in bot
  switchBoard = new conversation(robot);

  robot.respond /acciones git hub con issues/, (msg) ->
    showDialog(msg, true)

  robot.respond /Quiero ver los usuarios del sistema/i, (msg) ->
    github.get "#{endPointGitHub}/contents/CONTRIBUTORS.json", {}, (contributors) ->
     content = JSON.parse new Buffer(contributors.content, 'base64').toString()
     for i, index in  content.contributors
      msg.send "Usuario del sistema número #{index + 1}: #{i.name}"

  robot.respond /Quiero (.*) issue número (.*)/i, (res) ->
    respondUser = res.match[1]
    numberIssue = res.match[2]
    if respondUser is "Aceptar"
      getIssues(numberIssue, {}).then (issue) ->
       messageToCommit = JSON.parse issue.body
       res.http('https://raw.githubusercontent.com/BEEVA-bots-poc/access/master/CONTRIBUTORS.json').get() (err, httpRes, body) ->
        users = JSON.parse body
        users.contributors.push (messageToCommit)
        github.get "#{endPointGitHub}/contents/CONTRIBUTORS.json", {}, (infoCommit) ->
         contentCommit = new Buffer(JSON.stringify users).toString('base64')
         param = {
          message: "Added new User to repo",
          content: contentCommit,
          sha: infoCommit.sha
         }
         github.put "#{endPointGitHub}/contents/CONTRIBUTORS.json", param, (issue) ->
          res.send "----- ACEPTANDO ISSUE ----"
          github.patch "#{endPointGitHub}/issues/#{numberIssue}", {state: "closed"}, (issue, error) ->
           res.send "OK. He aceptado la issue #{numberIssue} y he añadido el usuario al contributors"
    else if respondUser is "Responder"
      param = {
       body: "El formato de la issue tiene que ser tipo JSON para que podamos identificarla. Debe tener los campos de name, email y user, Gracias =)"
      }
      github.post "#{endPointGitHub}/issues/#{numberIssue}/comments", param, (issue, error) ->
       if error then console.log error
       res.send "Contestada la issue #{numberIssue} al no cumplir los requisitos previos"
    else
      github.patch "#{endPointGitHub}/issues/#{numberIssue}", {state: "closed"}, (issue, error) ->
       if error then console.log error
       res.send "OK. He cerrado la issue #{numberIssue} al no cumplir los requisitos previos"

  #Initialize a dialog with bot
  showDialog = (msg, initial) ->
   dialog = switchBoard.startDialog(msg);

   if initial
    msg.reply "¿Buenos días, que deseas hacer con las issues?"
   else
    msg.reply "Deseas salir o realizar alguna petición más"

   dialog.addChoice /listar/i, (msg2) ->
    viewIssue(msg2)
   dialog.addChoice /ver la issue (.*)/i, (msg2) ->
    numberIssue = msg2.match[1]
    viewSpecificIssue(msg2, numberIssue)
   dialog.addChoice /salir/, (msg3) ->
    msg3.reply "Un placer asistirte. Good bye!"

  #Method to view all issues
  viewIssue = (msg) ->
    getIssues(null, {}).then (issues) ->
      issues = issues.sort (a,b) -> a.number > b.number
      texts = []
      for i in issues
        texts.push "[#{i.number}] #{i.title} realizada por #{i.user.login} con el contenido #{i.body}"
      text = texts.join '\n'
      msg.send "Tus issues son:\n#{text}"
      showDialog(msg)

  #Method to view specific issue
  viewSpecificIssue = (msg, numberIssue) ->
    getIssues(numberIssue, {}).then (issue) ->
     msg.send "[#{issue.number}] #{issue.title} realizada por #{issue.user.login} con el contenido #{issue.body}\n"
     showDialog(msg)

  #Method get issues (all or specific issue)
  getIssues = (numberIssue, state) ->
    return new Promise (resolve, reject) ->
     number = if numberIssue then "/#{numberIssue}" else ""
     return github.get "#{endPointGitHub}/issues#{number}", state, (issue) ->
      resolve issue
