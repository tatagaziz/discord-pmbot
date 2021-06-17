FROM ruby:latest
ARG MARIADB_VERSION=10.2.37
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update -qq && apt-get install -y nodejs npm yarn
WORKDIR /discord-pmbot
COPY . .
RUN bundle install \
    && npm install \
    && yarn
EXPOSE 3000

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

CMD ["rails","server","-b","0.0.0.0"]