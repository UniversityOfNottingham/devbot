# Devbot

Devbot is the University of Nottingham Application Development team's instance of [Hubot](https://hubot.github.com/).

It's used exclusively for the App Dev Slack team, to provide useful integration functionality through a single scriptable point.

This repository also contains utility bits for running hubot inside a simple node-js Docker container.

## Usage

1. Have [Docker](https://www.docker.com/).
1. Set the `HUBOT_SLACK_TOKEN` environment variable
1. Inside the repository root: `docker-compose up`

Alternatively if you have a [Rancher] infrastructure you can `rancher-compose up` as appropriate

Note for testing: you can specify the environment variable temporarily as follows:

- bash and derivatives:
    - `HUBOT_SLACK_TOKEN=xxxxxxxxxxxx docker-compose up`
    - the environment variable only applies to that command
- powershell
    - `& { $env:HUBOT_SLACK_TOKEN='xxxxxxxxxxxx'; docker-compose up }`
    - the environment variable only applies to the current powershell session

## Contributing

We have some issues. Feel free to make pull requests against them.

We are more likely to consider and accept pull requests against existing issues (which we can curate)
rather than arbitrary pull requests that add spammy external scripts that nobody asked for.

If you are using our stuff (the dockerfile, custom scripts etc.) and encounter problems with them, feel free to submit issues detailing your experiences,
and if appropriate make pull requests to rectify them.

## License

The source here is all under the MIT license. Feel free to take any of our modified or original scripts, or the Docker bits.

[Rancher]: https://rancher.com