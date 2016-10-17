# Description:
#   Provide links to reddit from shorthands
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   /r/gifs - will provide a link to https://reddit.com/r/gifs
#   /u/beforan - will provide a link to https://reddit.com/user/beforan
#   /m/reddit/redditnews - will provide a link to https://reddit.com/user/reddit/m/redditnews
# Author:
#   beforan

module.exports = (robot) ->
  robot.hear /\/(\w)\/(\w+)(?\/(\w+))?/, (msg) ->
    linktype = "#{msg.match[1]}"
    linktarget = "#{msg.match[2]}"
    multireddit = "#{msg.match[3]}"
    
    switch linktype
      when "r", "u"
        msg.send "https://reddit.com/#{linktype}/#{linktarget}"
      when "m"
        msg.send "https://reddit.com/user/#{linktarget}/m/#{multireddit}"