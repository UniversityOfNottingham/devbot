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
#   hubot repo get <repo or project name> -- exact match
#   hubot repo search <partial repo name> -- search
#   hubot repo search project <partial repo name> -- search projects
#   hubot repo create <name> <project> creates a repo in the given project, creates project if necessary
#
# Author:
#   beforan

baseUrl = "https://api.bitbucket.org/2.0"
teamName = process.env.BITBUCKET_TEAM_NAME
apiKey = process.env.BITBUCKET_API_KEY
authHeader = 'Basic ' + new Buffer(teamName + ':' + apiKey).toString('base64')

module.exports = (robot) ->

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

  # repo get <repo or project name>
  # robot.respond /repo\sget\s(.+)$/i, (msg) ->
  #   name = msg.match[1]

  #   attachments = []

  #   # direct match project name
  #   query = encodeURIComponent("name=\"#{name}\"")
  #   fields = "size,values.links.html.href,values.name"
  #   url = "#{baseUrl}/teams/#{teamName}/projects/?q=#{query}&fields=#{fields}"
  #   msg.http(url)
  #     .headers(Authorization: authHeader)
  #     .get() (err, res, body) ->
  #       if res.statusCode == 404
  #         return msg.send 'team "#{teamName}" does not exist'
  #       else
  #         json = JSON.parse(body)

  #         if json.size > 0
  #           projects = json.values
  #           attachmentsText = []

  #           for proj, i in projects
  #             attachmentsText.push "<#{proj.links.html.href}|#{proj.name}>"

  #           attachment = { "text": attachmentsText.join('\n') }
  #           attachment.pretext = "#{json.size} project#{if json.size > 1 then "s" else ""}"
  #           attachments.push attachment
    
  #       # all done? next http call
  #       # direct match repo name
  #       fields = "values.links.html.href,values.name,values.project.name,values.project.links.html.href"
  #       query = encodeURIComponent("name=\"#{name}\"")
  #       url = "#{baseUrl}/repositories/#{teamName}/?q=#{query}&fields=#{fields}"
  #       msg.http(url)
  #         .headers(Authorization: authHeader)
  #         .get() (err, res, body) ->
  #           if res.statusCode == 404
  #             return msg.send 'team "#{teamName}" does not exist'
  #           else
  #             json = JSON.parse(body)

  #             if json.size > 0
  #               repos = json.values
  #               attachmentsText = []

  #               for repo, i in repos
  #                 attachmentsText.push "<#{repo.links.html.href}|#{repo.name}> (<#{repo.project.links.html.href}|#{repo.project.name}> project)"

  #               attachment = { "text": attachmentsText.join('\n') }
  #               attachment.pretext = "#{json.size} repo#{if json.size > 1 then "s" else ""}"
  #               attachments.push attachment
            
  #           # all done? next http call
  #           # direct match repo slug
  #           fields = "links.html.href,name,project.name,project.links.html.href"
  #           url = "#{baseUrl}/repositories/#{teamName}/#{encodeURIComponent(name)}/?fields=#{fields}"
  #           msg.http(url)
  #             .headers(Authorization: authHeader)
  #             .get() (err, res, body) ->
  #               if res.statusCode != 404
  #                 repo = JSON.parse(body)
  #                 attachments.push {
  #                   "text": "<#{repo.links.html.href}|#{repo.name}> (<#{repo.project.links.html.href}|#{repo.project.name}> project)",
  #                   "pretext": "1 repo"
  #                 }

  #               # all done: send a message of some kind
  #               if attachments.length > 0
  #                 msg.send {
  #                   "attachments": attachments
  #                 }
  #               else
  #                 msg.send "no results"

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
  robot.respond /repo\ssearch\sproject\s(.+)$/i, (msg) ->
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
  searchRepos = (msg, searchTerm, fields) ->
    fields = fields || "size,values.links.html.href,values.name,values.project.name,values.project.links.html.href"
    query = encodeURIComponent "name~\"#{searchTerm}\"" #case insensitive contains
    url = "#{baseUrl}/repositories/#{teamName}/?q=#{query}&fields=#{fields}"

    new Promise (resolve, reject) ->
      msg.http(url)
        .headers(Authorization: authHeader)
        .get() (err, res, body) ->
          if res.statusCode == 404
            reject error: message: 'team "#{teamName}" does not exist'
          else
            resolve JSON.parse(body)
  
  #search projects
  searchProjects = (msg, searchTerm, fields) ->
    fields = fields || "size,values.links.html.href,values.name"
    query = encodeURIComponent "name~\"#{searchTerm}\"" #case insensitive contains
    url = "#{baseUrl}/teams/#{teamName}/projects/?q=#{query}&fields=#{fields}"

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