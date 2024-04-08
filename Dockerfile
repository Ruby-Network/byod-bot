FROM ruby:3

WORKDIR /app
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev
COPY . . 
RUN bundle install
ENV DOCKER=true
EXPOSE 9292

CMD ["bundle", "exec", "ruby", "cli/cli.rb", "start"]
