<div align="center">
         
<img src="https://socialify.git.ci/ruby-network/byod-bot/image?description=1&font=Inter&forks=1&issues=1&language=1&name=1&owner=1&pattern=Circuit%20Board&pulls=1&stargazers=1&theme=Dark" alt="byod-bot" width="640" height="320" />

</div>

---
## Join our Discord server for support and updates!
[![Ruby Network Discord](https://invidget.switchblade.xyz/bXJCZJZcJe?theme=dark)](https://discord.gg/bXJCZJZcJe)

---
## Current supported reverse proxies:
- [x] Caddy - Setup guide [here](#caddy)
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

> [!NOTE]
> When setting up manually, you can use sqlite3 instead of PostgreSQL.
> 
> To use sqlite, just pass the `--sqlite` flag to the `bundle exec ruby cli/cli.rb start` command.
>
> Example: `bundle exec ruby cli/cli.rb start --sqlite`
>
> This is ***not recommended*** for production use.

1. Clone the repository.
2. Run `bundle install` to install the required gems.
3. Run `bundle exec ruby cli/cli.rb start` to start the bot. You will be prompted to enter the required environment variables.


### Reverse Proxy setup 

#### Caddy 

- Caddy is the easiest reverse proxy to setup with the bot.

1. Install Caddy by following the instructions [here](https://caddyserver.com/docs/install).
2. Create a new file in the Caddyfile format.
3. Add the following configuration to the file:
```caddy
{
        on_demand_tls {
                ask http://yourIPToTheBotServer:9292/domainCheck/
                interval 2m
                burst 5
        }
}

https:// {
        tls {
                on_demand
        }
        reverse_proxy yourserversip:port
}
```

4. Replace `yourIPToTheBotServer` with the IP address of the server running the bot.
5. Replace `yourserversip:port` with the IP address and port of the server you want to reverse proxy to.

