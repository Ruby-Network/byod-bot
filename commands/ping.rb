#Basic ping command for now
@bot.register_application_command(:ping, "Responds with Pong!", server_id: ENV['GUILD_ID'])

@bot.application_command(:ping) do |event|
  event.respond(content: "Pong!", ephemeral: true)
end
