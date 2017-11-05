# Description
#   A Hubot script managing Github issues
#   You need acquire a token first:
#     $ curl -i https://api.github.com/authorizations -d '{"note":"githubot","scopes":["repo"]}' -u "yourusername"
#     $ export HUBOT_GITHUB_TOEKN=token_value
#
# Commands:
#   hubotslack listar issues - list up issues
#

repo  = "BEEVA-bots-poc"

module.exports = (robot) ->
  github = require('githubot')(robot)

  robot.respond /listar issues/i, (msg) ->
    github.get "https://api.github.com/repos/#{repo}/issues?client_id=ade66cfc15643918f9cc&client_secret=005e038f42787e5d1521a4ec2114ae01e347a0cb", {}, (issues) ->
      issues = issues.sort (a,b) -> a.number > b.number
      texts = ["https://github.com/#{repo}/issues"]
      for i in issues
        texts.push "[#{i.number}] #{i.title}"
      text = texts.join '\n'
      msg.reply "I'm listing up your issues\n#{text}"
