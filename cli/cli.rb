require 'thor'
require 'colorize'
require 'readline'
require 'tty-prompt'

class ByodCLI < Thor 
  desc "start", "Start the bot (with some options)"
  def start 
    puts "Starting the bot...".green
    system("bundle exec ruby main.rb")
  end
end
