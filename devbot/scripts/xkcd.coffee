# Description:
#   Grab XKCD comic image urls
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot xkcd - The latest XKCD comic
#   hubot xkcd #<num> - XKCD comic <num>
#   hubot xkcd ? - XKCD comic <num>
#   hubot xkcd <phrase> - XKCD comic relevant to <phrase>
#
# Author:
#   twe4ked
#   Hemanth (fixed the max issue)
#   Kelvin Zhang <me@iamkelv.in> (hubot-relevant-xkcd)
#
# Modified
# beforan (changed commands to make relevant search easier and merged Kelvin's relevant script into here')

module.exports = (robot) ->
  robot.respond /xkcd?$/i, (msg) ->
    msg.http("http://xkcd.com/info.0.json")
      .get() (err, res, body) ->
        if res.statusCode == 404
          msg.send 'Comic not found.'
        else
          object = JSON.parse(body)
          msg.send object.title, object.img, object.alt

  robot.respond /xkcd\s+#(\d+)/i, (msg) ->
    num = "#{msg.match[1]}"

    msg.http("http://xkcd.com/#{num}/info.0.json")
      .get() (err, res, body) ->
        if res.statusCode == 404
          msg.send 'Comic #{num} not found.'
        else
          object = JSON.parse(body)
          msg.send object.title, object.img, object.alt

  robot.respond /xkcd\s+\?/i, (msg) ->
    msg.http("http://xkcd.com/info.0.json")
          .get() (err,res,body) ->
            if res.statusCode == 404
               max = 0
            else
               max = JSON.parse(body).num 
               num = Math.floor((Math.random()*max)+1)
               msg.http("http://xkcd.com/#{num}/info.0.json")
               .get() (err, res, body) ->
                 object = JSON.parse(body)
                 msg.send object.title, object.img, object.alt
    
  robot.respond /xkcd\s+([^#].+)/i, (msg) ->
    phrase = "#{msg.match[1]}"

    # Get a relevant XKCD by phrase
    msg.http("https://relevantxkcd.appspot.com/process?action=xkcd&query=#{phrase}")
    .get() (err, res, body) ->
      if res.statusCode != 200
        msg.send 'An error has occurred. Is https://relevantxkcd.appspot.com/ up?'
      else
        # Extract appropriate data from response
        responseData = body.split(' ')
        percentageCertainty = responseData[0]
        comicNumber = parseInt(responseData[2], 10)

        # Get the comic details from XKCD
        msg.http("http://xkcd.com/#{comicNumber}/info.0.json")
        .get() (err, res, body) ->
          if res.statusCode == 404
            msg.send 'Comic #{comicNumber} not found.'
          else
            object = JSON.parse(body)
            msg.send object.title, object.img, object.alt

