<div align="center">
         
<img src="https://socialify.git.ci/ruby-network/byod-bot/image?description=1&font=Inter&forks=1&issues=1&language=1&name=1&owner=1&pattern=Circuit%20Board&pulls=1&stargazers=1&theme=Dark" alt="byod-bot" width="640" height="320" />

</div>

---
## Join our Discord server for help, support, and updates
[![Ruby Network Discord](https://invidget.switchblade.xyz/bWgw8469VS?theme=dark)](https://discord.gg/bWgw8469VS)

---
## Current supported reverse proxies:
- [x] Caddy 
  - [x] On Demand TLS - [Guide](#caddy)
- [x] Nginx 
    - [Guide](#nginx)
    - Want to learn more about How I did it? [Click here](https://motortruck1221.com/blog/nginx-byod)

## Description
A discord bot allowing anyone to implement BYOD (bring your own domain) into their service (semi) easily.

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
---

#### NGINX 

- NGINX is *slightly* more involved to setup with the bot.
- One caveat is that you will need to use [openresty](https://openresty.org/en/) over standard NGINX.

1. Install openresty by following the instructions [here](https://openresty.org/en/installation.html).
  - Or, if you are using Ubuntu 22.04 LTS, you can use our bash script to install openresty (and other dependencies):
  ```bash
    curl -s https://raw.githubusercontent.com/ruby-network/byod-bot/main/scripts/nginx.sh | bash
  ```
  - Using the script will allow you to skip step 1 through 3.

1a. Also install [OPM](https://opm.openresty.org/) if your distribution does not have it.

2. If you were previously using NGINX, you will need to disable it:
```bash
sudo systemctl stop nginx 
sudo systemctl disable nginx
```

3. Then you need to generate some fallback certificates:
```bash
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 -out /etc/openresty/account.key 
```
```bash
openssl req -newkey rsa:2048 -nodes -keyout /etc/openresty/default.key -x509 -days 365 -out /etc/openresty/default.pem
```
or as one command:
```bash
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 -out /etc/openresty/account.key && openssl req -newkey rsa:2048 -nodes -keyout /etc/openresty/default.key -x509 -days 365 -out /etc/openresty/default.pem 
```

4. If you have a complicated nginx config, you should back it up:
```bash
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
```
and then move it to the openresty directory:
```bash
sudo mv /etc/nginx/nginx.conf /etc/openresty/nginx.conf #(or /usr/local/openresty/nginx.conf)
```

5. Then, in which ever way you configure your sites, add what you need from the following example:
```nginx
resolver 8.8.8.8 ipv6=off;
lua_shared_dict acme 16m;
lua_ssl_trusted_certificate /etc/ssl/certs/ca-certificates.crt;
lua_ssl_verify_depth 2;
init_by_lua_block {
        require("resty.acme.autossl").init({
            tos_accepted = true,
            account_key_path = "/etc/openresty/account.key",
            account_email = "youremail@yourdomain.com",
            domain_whitelist = nil,
            blocking = true,
            staging = true,
        })
    }

init_worker_by_lua_block {
        require("resty.acme.autossl").init_worker()
}

server {
    #listen 80 default_server;
    #listen [::]:80 default_server;
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name yourmainserver.com;
    ssl_certificate /etc/openresty/default.pem;
    ssl_certificate_key /etc/openresty/default.key;
    ssl_certificate_by_lua_block {
            require("resty.acme.autossl").ssl_certificate()
    }
    location / {
        access_by_lua_block {
            local res = ngx.location.capture("/domainCheck/?domain=" .. ngx.escape_uri(ngx.var.host))
            if res.status ~= 200 then
                ngx.log(ngx.WARN, "Domain not allowed: ", ngx.var.host)
                return ngx.exit(ngx.HTTP_FORBIDDEN)
            end
        }
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'Upgrade';
        proxy_connect_timeout 10;
        proxy_send_timeout 90;
        proxy_read_timeout 90;
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;
        proxy_temp_file_write_size 256k;
        proxy_pass http://localhost:9292;  # Adjust the URL if needed
    }
    location /.well-known {
        access_by_lua_block {
            local res = ngx.location.capture("/domainCheck/?domain=" .. ngx.escape_uri(ngx.var.host))
            if res.status ~= 200 then
                ngx.log(ngx.WARN, "Domain not allowed: ", ngx.var.host)
                return ngx.exit(ngx.HTTP_FORBIDDEN)
            end
        }
        content_by_lua_block {
            require("resty.acme.autossl").serve_http_challenge()
        }
    }
    location /domainCheck {
        internal;
        proxy_pass http://localhost:9292/domainCheck;  # Adjust the URL if needed
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

6. Voila! You should now have a working NGINX reverse proxy with the bot. Feel free to ask for help in the [Discord Server](#join-our-discord-server-for-help-support-and-updates).
