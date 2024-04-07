@bot.register_application_command(:list, "List all of the domains you have added", server_id: ENV['GUILD_ID'])

@bot.application_command(:list) do |event|
  event.defer
  domains = findAllDomainsToUser(event.user.id)
  if domains.count == 0
    event.send_message(content: "You have not added any domains!", ephemeral: true)
  else
    embed = Discordrb::Webhooks::Embed.new
    embed.title = "Domains"
    embed.description = "Here are the domains you have added"
    embed.color = 0xffffff
    domains.each do |domain|
      embed.add_field(name: "------", value: "[#{domain[:domain]}](https://#{domain[:domain]})", 
                      inline: false)
    end
    embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Created By Ruby Network (MotorTruck1221) | https://dsc.gg/rubynetwork")
    embed.timestamp = Time.now
    event.send_message(embeds: [embed], ephemeral: true)
  end
end
