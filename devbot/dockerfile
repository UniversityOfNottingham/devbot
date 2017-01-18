FROM risingstack/alpine:3.4-v6.7.0-4.0.0
MAINTAINER Jonathan Couldridge, Jonathan.Couldridge@nottingham.ac.uk

ENV BOTDIR /opt/devbot
ENV HUBOT_PORT 8080

ENV HUBOT_ADAPTER slack
ENV HUBOT_SLACK_TOKEN xxxxxxxxxxxxxxxxxxxxx

EXPOSE ${HUBOT_PORT}

COPY ./devbot ${BOTDIR}

WORKDIR ${BOTDIR}

RUN npm install

RUN chmod a+x bin/hubot

CMD bin/hubot