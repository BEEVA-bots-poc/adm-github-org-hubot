repo = "BEEVA-bots-poc"

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
			msg.send({
		    "text": "[#{issue.number}] #{issue.title} realizada por #{issue.user.login} con el contenido #{issue.body}",
		    "attachments": [
		      {
		        "text": "#{issue.body}",
		        "fallback": "You are unable to choose an action to issue",
		        "callback_id": "wopr_issue",
		        "color": "#3AA3E3",
		        "attachment_type": "default",
		        "actions": [
		          {
		            "name": "issue",
		            "text": "Aceptar",
		            "type": "button",
								"style": "good",
		            "value": "accept"
		          },
		          {
		            "name": "issue",
		            "text": "Responder",
		            "type": "button",
								"style": "warning",
		            "value": "respond"
		          },
		          {
		            "name": "issue",
		            "text": "Rechazar",
		            "style": "danger",
		            "type": "button",
		            "value": "discard",
		            "confirm": {
		              "title": "¿Rechazar issue?",
		              "text": "¿Estás seguro que deseas rechazar la issue?",
		              "ok_text": "Yes",
		              "dismiss_text": "No"
		            }
		          }
		        ]
		      }
		    ]
		  })
