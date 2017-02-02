# Description:
#   UoN bitbuckety stuff
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot repo -- last 5 updated repos
#   hubot repo search <partial repo name> -- search
#   hubot repo searchprojects <partial project name> -- search projects
#   hubot repo create <name> <project> -- creates a repo in the given project, creates project if necessary
#
# Author:
#   beforan

baseUrl = "https://api.bitbucket.org/2.0"
teamName = process.env.BITBUCKET_TEAM_NAME
apiKey = process.env.BITBUCKET_API_KEY
authHeader = 'Basic ' + new Buffer(teamName + ':' + apiKey).toString('base64')

module.exports = (robot) ->
  #----------
  # listeners
  #----------
  
  # repo
  robot.respond /repo$/i, (msg) ->
    msg.http("#{baseUrl}/repositories/#{teamName}?sort=-updated_on&fields=values.name,values.links.html.href,values.updated_on&pagelen=5")
      .headers(Authorization: authHeader)
      .get() (err, res, body) ->
        if res.statusCode == 404
          msg.send 'user "#{teamName}" does not exist'
        else
          object = JSON.parse(body)
          attachmentsText = []
          for repo, i in object.values
            attachmentsText.push "[#{dateformat(repo.updated_on)}] <#{repo.links.html.href}|#{repo.name}>"

          msg.send attachments: [
            text: attachmentsText.join('\n'),
            pretext: "5 most recently updated repositories"
          ]

  # repo search <repo>
  robot.respond /repo\ssearch\s(.+)$/i, (msg) ->
    name = msg.match[1]

    searchRepos(msg, name)
      .then (result) ->
        attachmentsText = []
        for r in result.values
          attachmentsText.push "<#{r.links.html.href}|#{r.name}>"
        
        if attachmentsText.length > 0
          pretextCount = if attachmentsText.length < result.size then "Showing #{attachmentsText.length} of #{result.size}" else "#{result.size}"
          msg.send attachments: [
            fallback: "#{result.size} repo#{if result.size != 1 then "s" else ""} found for \"#{name}\"",
            text: attachmentsText.join('\n'),
            pretext: "#{pretextCount} repo#{if result.size != 1 then "s" else ""} found"
          ]
        else
          msg.send "No results found"
      .catch (err) ->
        msg.send err.error.message
  
  # repo search project <project>
  robot.respond /repo\ssearchprojects\s(.+)$/i, (msg) ->
    name = msg.match[1]

    searchProjects(msg, name)
      .then (result) ->
        attachmentsText = []
        for p in result.values
          attachmentsText.push "<#{p.links.html.href}|#{p.name}>"
        
        if attachmentsText.length > 0
          pretextCount = if attachmentsText.length < result.size then "Showing #{attachmentsText.length} of #{result.size}" else "#{result.size}"
          msg.send attachments: [
            fallback: "#{result.size} project#{if result.size != 1 then "s" else ""} found for \"#{name}\"",
            text: attachmentsText.join('\n'),
            pretext: "#{pretextCount} project#{if result.size != 1 then "s" else ""} found"
          ]
        else
          msg.send "No results found"
      .catch (err) ->
        msg.send err.error.message

  #search repos
  #------------------
  # utility functions
  #------------------

  #search repos by name
  searchRepos = (msg, searchTerm, fields) ->
    queryRepos msg, "name~\"#{searchTerm}\"", fields || "size,values.links.html.href,values.name"

  #search projects by name
  searchProjects = (msg, searchTerm, fields) ->
    queryProjects msg, "name~\"#{searchTerm}\"", fields || "size,values.links.html.href,values.name"

  # query repos
  queryRepos = (msg, query, fields) ->
    query = encodeURIComponent query
    url = "#{baseUrl}/repositories/#{teamName}/?q=#{query}#{if fields then "&fields=#{fields}" else ""}"

    new Promise (resolve, reject) ->
      msg.http(url)
        .headers(Authorization: authHeader)
        .get() (err, res, body) ->
          if res.statusCode == 404
            reject error: message: 'team "#{teamName}" does not exist'
          else
            resolve JSON.parse(body)

  # query projects
  queryProjects = (msg, query, fields) ->
    query = encodeURIComponent query
    url = "#{baseUrl}/teams/#{teamName}/projects/?q=#{query}#{if fields then "&fields=#{fields}" else ""}"

    new Promise (resolve, reject) ->
      msg.http(url)
        .headers(Authorization: authHeader)
        .get() (err, res, body) ->
          if res.statusCode == 404
            reject error: message: 'team "#{teamName}" does not exist'
          else
            resolve JSON.parse(body)
  
  #date format
  dateformat = (date) ->
    new Date(date).toISOString().replace(/T/, ' ').replace(/\..+/, '')