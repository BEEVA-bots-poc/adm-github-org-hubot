#adm-github-org-hubot-slack

Manage contributos in organization with hubot with slack

See [`scripts/issues.coffee`](scripts/issues.coffee) for full documentation.

## Installation

To install your hubot script, you should view next documentations

[deploying in local]: https://hubot.github.com/docs/
[deploying in heroku]: https://hubot.github.com/docs/deploying/heroku/


## Configuration

  * `HUBOT_GITHUB_TOKEN` - The key used to encrypt your tokens in the hubot and be able to access the private Github API.
  * `HUBOT_SLACK_TOKEN` - The key used to encrypt your tokens in the hubot and be able to access to Slack
  * `HUBOT_HEROKU_KEEPALIVE_URL` - It's optional. If you configured this option, your bot doesn't sleep permanently

## Sample Interaction

```
user1>> @hubotslack acciones git hub con issues

hubotslack> ¿Buenos días, que deseas hacer con las issues?

user1>> @hubotslack listar

hubotslack> Tus issues son:
    [1] <Issue's name> realizada por <user> con el contenido <contenido>
Deseas salir o realizar alguna petición más?

user1>> ver issue <Issue's number>

hubotslack> [6] test report realizada por josex2r con el contenido checking report is successfully sent
     Deseas Aceptar, Responder, Cerrar u otras opciones disponibles?

user1>> aceptar/responder/cerrar

//Aceptar
hubotslack> OK. He aceptado la issue <Issue's number> y he añadido el usuario al contributors
//Responder
hubotslack> ¿Qué deseas contestar al usuario?
user1>> text to respond to the user
hubotslack> ¿Estás seguro de la respuesta?: <text>
user1>> si/no
//si
hubotslack> Contestada la issue #{numberIssue}
//no
hubotslack> ¿Deseas salir o volver a escribir?
user1>> text to respond to the user
//Cerrar
hubotslack> Issue número: <Issue's number> cerrada.

user1>> @hubotslack ver usuarios
hubotslack> Usuario del sistema: <User's name>
```
