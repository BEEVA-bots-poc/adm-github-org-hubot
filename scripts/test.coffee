module.exports = (robot) ->
  robot.hear /la/i, (res) ->
    robot.http("https://api.github.com/repos/BEEVA-bots-poc/issues?client_id=ade66cfc15643918f9cc&client_secret=005e038f42787e5d1521a4ec2114ae01e347a0cb")
    .get() (err, response, body) ->
      # err & response status checking code here
      res.send "response #{response}"
      res.send "body #{body}"
