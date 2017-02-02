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
#   hubot repo get <repo or project name> -- get links to repos or projects with an exact name (case insensitive)
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

  # repo get <repo or project name> # TODO repo slugs, project keys?
  robot.respond /repo\sget\s(.+)$/i, (msg) ->
    name = msg.match[1]
    fields = []

    # these are synchronous right now, but could easily be async...
    Promise.all([
      getProjectsByName(msg, name, "values.name,values.links.html.href"),
      getReposByName(msg, name, "values.name,values.links.html.href")
    ])
      .then (results) ->
        projects = []
        for p in results[0]
          projects.push "<#{p.links.html.href}|#{p.name}>"
        if projects.length > 0 then fields.push title: "Projects", value: projects.join('\n')

        repos = []
        for r in results[1]
          repos.push "<#{r.links.html.href}|#{r.name}>"
        if repos.length > 0 then fields.push title: "Repositories", value: repos.join('\n')

        if fields.length > 0
          msg.send attachments: [
            fallback: "Results for repo get #{name}",
            fields: fields
          ]
        else
          msg.send "No results found"

  #------------------
  # utility functions
  #------------------

  #search repos by name
  searchRepos = (msg, searchTerm, fields, pagelen) ->
    queryRepos msg, "name~\"#{searchTerm}\"", fields || "size,values.links.html.href,values.name", pagelen

  #search projects by name
  searchProjects = (msg, searchTerm, fields, pagelen) ->
    queryProjects msg, "name~\"#{searchTerm}\"", fields || "size,values.links.html.href,values.name", pagelen

  # get projects by exact case insensitive name match
  getProjectsByName = (msg, name, fields) ->
    searchProjects(msg, name, fields || "size,values.name,values.key", 100)
      .then (result) ->
        projects = []

        # theoretically in future need to deal with size > 100, but should be super unlikely
        for project in result.values
          if project.name.toLowerCase() == name.toLowerCase() then projects.push project
        
        projects
  
  # get repos by exact case insensitive name match
  getReposByName = (msg, name, fields) ->
    searchRepos(msg, name, fields || "size,values.name", 100)
      .then (result) ->
        repos = []

        # theoretically in future need to deal with size > 100, but should be super unlikely
        for repo in result.values
          if repo.name.toLowerCase() == name.toLowerCase() then repos.push repo
        
        repos

  # get project by key
  getProjectByKey = (msg, key, fields) ->
    new Promise (resolve, reject) ->
      msg.http("#{baseUrl}/teams/#{teamName}/projects/#{if fields then "?fields=#{fields}" else ""}")
        .headers(Authorization: authHeader)
        .get() (err, res, body) ->
          if res.statusCode == 404
            reject error: message: 'Project with key "#{key}" does not exist'
          else
            resolve JSON.parse(body)

  # query repos
  queryRepos = (msg, query, fields, pagelen) ->
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
  queryProjects = (msg, query, fields, pagelen) ->
    pagelen = if pagelen > 100 then 100 else pagelen || 10
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