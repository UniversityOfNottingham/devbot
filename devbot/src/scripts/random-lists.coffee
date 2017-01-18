# Description:
#   Configurable random list item selector
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot random <list> - output a random item from the specified list
#   hubot random <combo> - output a random item from each list in the combo in order
#
# Author:
#   beforan

lists = {
  "direction": [
    "clockwise",
    "anti-clockwise"
  ],
  "staircase": [
    "Reception",
    "Vending Machines",
    "Canteen",
    "Studio 11",
    "Post Room",
    "Transform"
  ]
}

combos = {
  "walk": [
    {
      "name": "first staircase",
      "list": "staircase"
    },
    "direction",
    {
      "name": "second staircase",
      "list": "staircase"
    }
  ]
}

module.exports = (robot) ->
  robot.respond /random\s+(.+)/i, (msg) ->
    identifier = "#{msg.match[1]}"

    # prioritise list
    if identifier of lists
      msg.send msg.random(lists[identifier])
    else if identifier of combos
      for c, i in combos[identifier].reverse() # reverse because coffeescript for loops iterate backwards >.<
        if typeof c is "string"
          msg.send "#{c}: #{msg.random(lists[c])}"
        else if typeof c is "object"
          msg.send "#{c.name}: #{msg.random(lists[c.list])}"