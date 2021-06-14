FROM ruby:latest
ARG MARIADB_VERSION=10.2.37
RUN apt-get update -qq && apt-get install -y nodejs npm
WORKDIR /discord-pmbot
COPY . .
RUN bundle install \
    && npm install
EXPOSE 3000

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

CMD ["rails","server","-b","0.0.0.0"]