@bot.register_application_command(:help, "Help", server_id: ENV['GUILD_ID'])

@bot.application_command(:help) do |event|
  event.defer
  # construct the embed 
  embed = Discordrb::Webhooks::Embed.new
  embed.title = "Help"
  embed.description = "Here are the commands and some common questions"
  embed.color = 0xffffff
  embed.add_field(name: "/add", value: "Adds a domain", inline: false)
  embed.add_field(name: "/delete", value: "Deletes a domain", inline: false)
  embed.add_field(name: "/list", value: "Lists all the domains", inline: false)
  embed.add_field(name: "/help", value: "Shows this message", inline: false)
  embed.add_field(name: "My Domain isn't working!", 
                  value: "Make sure the domain is pointed to the server IP and the proxy is disabled if you are using Cloudflare",
                  inline: false)
  embed.add_field(name: "How do I set this up for my server?", 
                  value: "You can find the source code and docs [here](https://github.com/ruby-network/byod-bot)
  If you need help, feel free to ask in the [support server](https://dsc.gg/rubynetwork)",
                  inline: false)
  embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Created By Ruby Network (MotorTruck1221) | https://dsc.gg/rubynetwork")
  embed.timestamp = Time.now
  event.send_message(embeds: [embed], ephemeral: true)
end
