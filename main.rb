require 'discordrb'
require 'colorize'
require 'dotenv'

Dotenv.load
@token = ENV['DISCORD_TOKEN']
@bot = Discordrb::Bot.new(token: @token, intents: [:server_members])
@bot.ready do |event|
  puts "Bot is ready and Online!".green
  @bot.update_status('online', 'for domains', nil, 0, false, 3)
end
Dir["#{File.dirname(__FILE__)}/commands/*.rb"].each { |file| require file }
@bot.run
