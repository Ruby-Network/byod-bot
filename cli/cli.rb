require 'thor'
require 'colorize'
require 'readline'
require 'tty-prompt'
require 'dotenv'

Dotenv.load

class ByodCLI < Thor 
  desc "start", "Start the bot"
  option :sqlite, type: :boolean, default: false, desc: "Use SQLite instead of PostgreSQL"
  def start 
    #if running in docker, completley ignore this
    if ENV['DOCKER'] != "true"
      if File.exist?(".env") == false
        File.open(".env", "w") do |f|
        end
      end
    end
    if ENV['REVERSE_PROXY'] == nil
      while true
        prompt = TTY::Prompt.new
        reverseProxy = prompt.select("Which reverse proxy do you use?", %w(caddy), required: true, default: "caddy")
        reverseProxyConfirm = prompt.yes?("Is #{reverseProxy} the correct reverse proxy?")
        if reverseProxyConfirm == false
          next
        else
          File.open(".env", "a") do |f|
            f.write("REVERSE_PROXY=#{reverseProxy}\n")
          end
          break
        end
      end
    end
    if ENV['GUILD_ID'] == nil
      while true
        prompt = TTY::Prompt.new
        guildID = prompt.ask("What is the ID of your server?", required: true)
        guildConfirm = prompt.yes?("Is #{guildID} the correct server ID?")
        if guildConfirm == false
          next
        else 
          File.open(".env", "a") do |f|
            f.write("GUILD_ID=#{guildID}\n")
          end
          break 
        end
      end
    end
    if ENV['DISCORD_TOKEN'] == nil
      prompt = TTY::Prompt.new
      token = prompt.mask("What is your Discord bot token?", required: true)
      File.open(".env", "a") do |f|
        f.write("DISCORD_TOKEN=#{token}\n")
      end
    end
    if ENV['SERVER_IP'] == nil
      prompt = TTY::Prompt.new
      serverIP = prompt.ask("What is the IP the server you want people to point there domains to?", required: true)
      File.open(".env", "a") do |f|
        f.write("SERVER_IP=#{serverIP}\n")
      end
    end
    if options[:sqlite] == true
      #delete any existing DATABSE key in the env 
      if ENV['DATABASE'] != "sqlite"
        #delete the key
        File.open(".env", "r+") do |f|
          f.each_line do |line|
            if line.include?("DATABASE")
              f.seek(-line.length, IO::SEEK_CUR)
              f.write("#" + line)
            end
          end
        end
        File.open(".env", "a") do |f|
          f.write("DATABASE=sqlite\n")
          ENV['DATABASE'] = "sqlite"
        end
      end
    else 
      if ENV['DATABASE'] != "postgres"
        #delete the key
        File.open(".env", "r+") do |f|
          f.each_line do |line|
            if line.include?("DATABASE")
              f.seek(-line.length, IO::SEEK_CUR)
              f.write("#" + line)
            end
          end
        end
        File.open(".env", "a") do |f|
          f.write("DATABASE=postgres\n")
        end
      end
    end
    if ENV['DATABASE'] == 'postgres' && ENV['DOCKER'] != "true"
      puts "Running setup for PostgreSQL database".yellow
      if ENV['DB_HOST'] == nil
        prompt = TTY::Prompt.new
        host = prompt.ask("What is the host of your PostgreSQL database?", required: true)
        File.open(".env", "a") do |f|
          f.write("DB_HOST=#{host}\n")
        end
      end
      if ENV['DB_USER'] == nil
        prompt = TTY::Prompt.new
        user = prompt.ask("What is the user of your PostgreSQL database?", required: true)
        File.open(".env", "a") do |f|
          f.write("DB_USER=#{user}\n")
        end
      end
      if ENV['DB_PASSWORD'] == nil
        prompt = TTY::Prompt.new
        password = prompt.mask("What is the password of your PostgreSQL database?", required: true)
        File.open(".env", "a") do |f|
          f.write("DB_PASSWORD=#{password}\n")
        end
      end
      if ENV['DB_NAME'] == nil
        prompt = TTY::Prompt.new
        database = prompt.ask("What is the name of your PostgreSQL database?", required: true)
        File.open(".env", "a") do |f|
          f.write("DB_NAME=#{database}\n")
        end
      end
    end
    puts "Starting the bot...".yellow
    system("bundle exec puma -e production &")
    system("bundle exec ruby main.rb")
  end
end

ByodCLI.start(ARGV)
