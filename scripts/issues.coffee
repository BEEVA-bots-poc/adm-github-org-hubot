# Description:
#   Allows Hubot to view/reply issues and add to organization
#
# Dependencies:
#   "githubot": "0.4.x"
#   "hubot-conversation": "^1.1.1"
#   "es6-promise": "^4.1.0",
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
#   hubot acciones git hub con issues
#    |
#     -> listar
#    |
#     -> ver issue <number>
#       |
#        -> aceptar
#       |
#        -> rechazar
#       |
#        -> responder
#    |
#     -> ver usuarios
#    |
#     -> salir
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

  #Initialize a dialog with bot
  showDialog = (msg, initial) ->
   dialog = switchBoard.startDialog(msg);

   if initial
    msg.reply "¿Buenos días, que deseas hacer con las issues?"
   else
    msg.reply "Deseas salir o realizar alguna petición más?"

   dialog.addChoice /listar/i, (msg2) ->
    viewIssue(msg2)
   dialog.addChoice /ver issue (.*)/i, (msg2) ->
    numberIssue = msg2.match[1]
    viewSpecificIssue(msg2, numberIssue)
   dialog.addChoice /ver usuarios/, (msg3) ->
    viewUsersInSystem(msg3)
   dialog.addChoice /salir/, (msg4) ->
    msg4.reply "Un placer asistirte. Good bye!"

  #Initialize a dialog with bot
  showDialogIssue = (msg, numberIssue, issue) ->
    dialog = switchBoard.startDialog(msg);

    msg.reply "Deseas Aceptar, Responder, Cerrar u otras opciones disponibles?"

    dialog.addChoice /aceptar/i, (msg1) ->
      acceptIssue(msg1, numberIssue, issue)
    dialog.addChoice /responder/i, (msg2) ->
      respondIssueDialog(msg2, numberIssue)
    dialog.addChoice /cerrar/, (msg3) ->
      closedIssue(msg3, numberIssue)
    dialog.addChoice /otras (.*)/, (msg4) ->
      showDialog(msg4)

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

  #Method to close issue
  acceptIssue = (msg, numberIssue, issue) ->
    github.get "https://api.github.com/users/#{issue.user.login}", {}, (userInfo) ->
      if !userInfo.email
        respondIssue(msg, numberIssue, "Debes rellenar tu email")
      else
        msg.http('https://raw.githubusercontent.com/BEEVA-bots-poc/access/master/CONTRIBUTORS.json').get() (err, httpRes, body) ->
          users = JSON.parse body
          users.contributors.push ({"name":userInfo.name,"email":userInfo.email,"git":userInfo.login})
          github.get "#{endPointGitHub}/contents/CONTRIBUTORS.json", {}, (infoCommit) ->
            contentCommit = new Buffer(JSON.stringify users).toString('base64')
            param = {
              message: "Added new User to repo",
              content: contentCommit,
              sha: infoCommit.sha
            }
            github.put "#{endPointGitHub}/contents/CONTRIBUTORS.json", param, (issue) ->
              github.patch "#{endPointGitHub}/issues/#{numberIssue}", {state: "closed"}, (issue, error) ->
                msg.send "OK. He aceptado la issue #{numberIssue} y he añadido el usuario al contributors"

  #Method to close issue
  closedIssue = (msg, numberIssue) ->
    github.patch "#{endPointGitHub}/issues/#{numberIssue}", {state: "closed"}, (issue, error) ->
      if error
        msg.send "Error, por favor intentalo más tarde"
        showDialog(msg)
      else
        msg.send "Issue número: #{numberIssue} cerrada."

  #Method to responde issue to user
  respondIssueDialog = (msg, numberIssue) ->
    dialog = switchBoard.startDialog(msg);

    msg.reply "¿Qué deseas contestar al usuario?"

    dialog.addChoice /(.*)/i, (msg1) ->
      text = msg1.match[1]
      msg1.reply "¿Estás seguro de la respuesta?: #{text}"

      dialog.addChoice /si/, (msg2) ->
        respondIssue(msg2, numberIssue, text)
      dialog.addChoice /no/, (msg3) ->
        msg1.reply "¿Deseas salir o volver a escribir?"

        dialog.addChoice /volver (.*)/, (msg2) ->
          respondIssueDialog(msg2, numberIssue)
        dialog.addChoice /salir/, (msg3) ->
          showDialog(msg3)

  #Method to view all users registered in repo
  respondIssue = (msg, numberIssue, text) ->
    param = {
      body: text
    }
    msg.send "#{numberIssue}"
    github.post "#{endPointGitHub}/issues/#{numberIssue}/comments", param, (issue, error) ->
      if error
        msg.send "Error, por favor intentalo más tarde"
        showDialog(msg)
      else
      msg.send "Contestada la issue #{numberIssue}"
      showDialog(msg)

  #Method to view all users registered in repo
  viewUsersInSystem = (msg) ->
    github.get "#{endPointGitHub}/contents/CONTRIBUTORS.json", {}, (contributors) ->
     content = JSON.parse new Buffer(contributors.content, 'base64').toString()
     for i in  content.contributors
      msg.send "Usuario del sistema número: #{i.name}"
    showDialog(msg)

  #Method to view specific issue and user can do actions with specific issue
  viewSpecificIssue = (msg, numberIssue) ->
    getIssues(numberIssue, {}).then (issue) ->
     msg.send "[#{issue.number}] #{issue.title} realizada por #{issue.user.login} con el contenido #{issue.body}\n"
     showDialogIssue(msg, numberIssue, issue)

  #Method get issues (all or specific issue)
  getIssues = (numberIssue, state) ->
    return new Promise (resolve, reject) ->
     number = if numberIssue then "/#{numberIssue}" else ""
     return github.get "#{endPointGitHub}/issues#{number}", state, (issue) ->
      resolve issue
