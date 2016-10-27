# Devbot

Devbot is the University of Nottingham Application Development team's instance of [Hubot](https://hubot.github.com/).

It's used exclusively for the App Dev Slack team, to provide useful integration functionality through a single scriptable point.

This repository also contains utility bits for running hubot inside a simple node-js Docker container.

## Usage

1. Have [Docker](https://www.docker.com/).
2. Inside the repository root:
    1. Build an image from source: `docker build -t devbot .`
    2. Run a container from the image: `docker run -d devbot [-e ENVIRONMENT_VARIABLES]`

## Contributing

We have some issues. Feel free to make pull requests against them.

We are more likely to consider and accept pull requests against existing issues (which we can curate)
rather than arbitrary pull requests that add spammy external scripts that nobody asked for.

If you are using our stuff (the dockerfile, custom scripts etc.) and encounter problems with them, feel free to submit issues detailing your experiences,
and if appropriate make pull requests to rectify them.

## License

The source here is all under the MIT license. Feel free to take any of our modified or original scripts, or the Docker bits.