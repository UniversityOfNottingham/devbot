FROM node
MAINTAINER Jonathan Couldridge, Jonathan.Couldridge@nottingham.ac.uk

ENV BOTDIR /opt/devbot

ENV HUBOT_PORT 8080
ENV HUBOT_ADAPTER slack
ENV HUBOT_NAME bot-name
ENV HUBOT_GOOGLE_API_KEY xxxxxxxxxxxxxxxxxxxxxx
ENV HUBOT_SLACK_TOKEN xxxxxxxxxxxxxxxxxxxxx
ENV HUBOT_SLACK_TEAM team-name
ENV HUBOT_SLACK_BOTNAME ${HUBOT_NAME}
ENV PORT ${HUBOT_PORT}

EXPOSE ${HUBOT_PORT}

COPY ./devbot ${BOTDIR}

WORKDIR ${BOTDIR}

RUN npm install

RUN chmod a+x bin/hubot

CMD bin/hubot