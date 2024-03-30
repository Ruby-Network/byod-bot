require 'thor'
require 'colorize'
require 'readline'
require 'tty-prompt'
require 'dotenv'

Dotenv.load

class ByodCLI < Thor 
  desc "start", "Start the bot"
  def start 
    #find the root of the project
    root = File.expand_path(File.dirname(__FILE__))
    #if there is no .env file, create one
    if File.exist?("#{root}/.env") == false
      File.open("#{root}/.env", "w") do |f|
      end
    end
    if ENV['REVERSE_PROXY'] == nil
      while true
        prompt = TTY::Prompt.new
        reverseProxy = prompt.select("Which reverse proxy do you use?", %w(caddy nginx apache), required: true, default: "caddy")
        reverseProxyConfirm = prompt.yes?("Is #{reverseProxy} the correct reverse proxy?")
        if reverseProxyConfirm == false
          next
        else
          File.open("#{root}/.env", "a") do |f|
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
          File.open("#{root}/.env", "a") do |f|
            f.write("GUILD_ID=#{guildID}\n")
          end
          break 
        end
      end
    end
    if ENV['DISCORD_TOKEN'] == nil
      prompt = TTY::Prompt.new
      token = prompt.mask("What is your Discord bot token?", required: true)
      File.open("#{root}/.env", "a") do |f|
        f.write("DISCORD_TOKEN=#{token}\n")
      end
    end
    puts "Starting the bot...".yellow
    system("bundle exec ruby main.rb")
  end
end

ByodCLI.start(ARGV)
