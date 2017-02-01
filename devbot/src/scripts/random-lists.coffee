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

lists =
  direction: [
    "clockwise",
    "anti-clockwise"
  ],
  staircase: [
    "Reception",
    "Vending Machines",
    "Canteen",
    "Studio 11",
    "Post Room",
    "Transform"
  ]

combos = 
  walk: [
      name: "First staircase",
      list: "staircase"
    ,
      name: "Direction",
      list: "direction"
    ,
      name: "Second staircase",
      list: "staircase"
  ]

module.exports = (robot) ->
  robot.respond /random\s+(.+)/i, (msg) ->
    identifier = msg.match[1]

    # prioritise list
    if identifier of lists
      msg.send msg.random(lists[identifier])
    else if identifier of combos
      fields = []
      for c, i in combos[identifier]
        if typeof c is "string"
          fields.push title: c, value: msg.random(lists[c])
        else if typeof c is "object"
          fields.push title: c.name, value: msg.random(lists[c.list])
      
      msg.send attachments: [
        fields: fields,
        pretext: "Random #{identifier}:"
      ]