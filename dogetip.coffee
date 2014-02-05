# Description:
#   Tip users with Dogecoin
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_DOGETIP_URL
#
# Commands:
#   hubot my doge address - Returns user's dogecoint address
#   hubot my doge balance - Returns user's dogecoin balance
#   hubot tip <user> <amount> doge - Tips <amount> doge to the user <to>
#
# Author:
#   Michael Mattax
QS = require 'querystring'
module.exports = (robot) ->

  robot.respond /my doge address/i, (msg) ->
    msg.send msg.message.user.dogeAddress

  robot.respond /my doge balance/i, (msg) ->
    msg.http(process.env.HUBOT_DOGETIP_URL)
      .path("/balance/#{msg.message.user.dogeAddress}")
      .get() (error, res, body) ->
        response = JSON.parse(body)
        switch res.statusCode
          when 200
            msg.send "#{response.balance}"
          else
            msg.send response.error

  robot.respond /@?([\w .\-_]+) has doge address (\w+)/i, (msg) ->
    name = msg.match[1]
    hash = msg.match[2].trim()

    users = robot.brain.usersForFuzzyName(name)
    if users.length is 1
      user = users[0]
      user.dogeAddress = hash
      msg.send "Ok. Doge address was set."
    else
      msg.send "I don't know " + name + "."
    
  robot.respond /tip @?([\w .\-_]+) (\d+) doge/i, (msg) ->

    name = msg.match[1]
    amount = msg.match[2]
    
    # Get the user and check for the doge addresss.
    users = robot.brain.usersForFuzzyName(name)
    if users.length is 1
      user = users[0]
      if not user.dogeAddress
        msg.send "I don't know " + name + "'s doge address."
    else
      msg.send "I don't know " + name + "."

    # Send the coin.
    if not msg.message.user.dogeAddress
      msg.send "I don't know your doge address."
    else
        data = QS.stringify
          from: msg.message.user.dogeAddress
          to: user.dogeAddress
          amount: amount

        msg.http(process.env.HUBOT_DOGETIP_URL)
          .path("/tip")
          .header('Content-Type', 'application/x-www-form-urlencoded')
          .post(data) (error, res, body) ->
            response = JSON.parse(body)
            switch res.statusCode
              when 200
                msg.send "http://dogechain.info/tx/#{response.transaction}"
              else
                msg.send response.error
