# Byod Bot

## Current supported reverse proxies:
- [x] Caddy
- [ ] Nginx
- [ ] Apache

## Description
A discord bot allowing anyone to implement BYOD (bring your own domain) into their service.

## Setup

### Requirements
- Ruby 3.0.0 or higher
- Bundler
- PostgreSQL server
- Discord bot token
Or use the Docker image to skip:
- Ruby
- Bundler
- PostgreSQL server

### Installation
There are two ways to install the bot, either by using Docker **RECOMMENDED** or by installing it manually.

#### Docker Compose

1. Get the `docker-compose.yml` file from the repository [here](https://github.com/ruby-network/byod-bot/blob/main/docker-compose.yml).
2. Edit the environment variables in the `docker-compose.yml` file.
3. Run `docker-compose up -d` to start the bot.

#### Docker Compose (Build from source)

1. Clone the repository.
2. Get the `docker-compose.build.yml` file from the repository [here](https://github.com/ruby-network/ruby/blob/main/docker-compose.build.yml).
3. Edit the environment variables in the `docker-compose.build.yml` file.
4. Run `docker-compose -f docker-compose.build.yml build` to build the bot.
5. Run `docker-compose -f docker-compose.build.yml up -d` to start the bot.

#### Manual Installation

1. Clone the repository.
2. Run `bundle install` to install the required gems.
3. Run `bundle exec ruby cli/cli.rb start` to start the bot. You will be prompted to enter the required environment variables.
