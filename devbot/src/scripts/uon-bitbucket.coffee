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
#   hubot repo <repo or project name> -- exact match, or search results
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

          msg.send {
            "attachments": [
              {
                "text": attachmentsText.join('\n'),
                "pretext": "5 most recently updated repositories"
              }
            ]
          }

  # repo <repo or project name>
  robot.respond /repo\ssearch\s(.+)$/i, (msg) ->
    name = msg.match[1]

    attachments = []

    # direct match projects first
    msg.http("#{baseUrl}/teams/#{teamName}/projects/?q=name+%3D+%22#{name}%22&fields=values.links.html.href,values.name")
      .headers(Authorization: authHeader)
      .get() (err, res, body) ->
        if res.statusCode == 404
          return msg.send 'team "#{teamName}" does not exist'
        else
          if body.size > 0
            projects = JSON.parse(body.values)
            attachmentsText = []

            for proj, i in projects
              attachmentsText.push "*Project:* <#{project.links.html.href}|#{project.name}>"

            if body.size > 0
              attachment = { "text": attachmentsText.join('\n') }
              attachment.pretext = "#{body.size} project#{body.size > 1 ? "s" : ""}"
              attachments.push attachment
    
    # direct match repos
    # msg.http("#{baseUrl}/teams/#{teamName}/projects/#{name}")
    #   .headers(Authorization: authHeader)
    #   .get() (err, res, body) ->
    #     if res.statusCode != 404
    #       project = JSON.parse(body)
    #       attachments.push = {
    #         "fallback": "Project: #{project.name} - #{project.links.html.href}",
    #         "text": "*Project:* <#{project.links.html.href}|#{project.name}>"
    #       }

    # msg.http("#{baseUrl}/repositories/#{teamName}?sort=-updated_on&fields=values.name,values.links.html.href,values.updated_on&pagelen=5")
    #   .headers(Authorization: authHeader)
    #   .get() (err, res, body) ->
    #     if res.statusCode == 404
    #       msg.send body.error.message
    #     else
    #       object = JSON.parse(body)
    #       for repo, i in object.values
    #         msg.send { text: "<#{repo.links.html.href}|#{repo.name}> - last updated: #{dateformat(repo.updated_on)}", unfurl_links: false }

  # repo create


  #date format
  dateformat = (date) ->
    new Date(date).toISOString().replace(/T/, ' ').replace(/\..+/, '')