@bot.register_application_command(:delete, "Delete a domain", server_id: ENV['GUILD_ID']) do |cmd|
  cmd.string("domain", "The domain you want to delete", required: true)
end

@bot.application_command(:delete) do |event|
  event.defer
  domains = findAllDomainsToUser(event.user.id)
  domain = event.options['domain']
  if isDomain(domain) == false 
    event.send_message(content: "Invalid domain!", ephemeral: true)
  else
    if domains.where(domain: domain).count == 0
      event.send_message(content: "Domain does not exist!", ephemeral: true)
    else
      #make sure the domain is owned by the user 
      if domains.where(domain: domain).first[:user].to_i == event.user.id.to_i
        deleteDomain(domain)
        event.send_message(content: "Deleted `#{domain}` from the server!", ephemeral: true)
      else
        event.send_message(content: "You do not own this domain!", ephemeral: true)
      end
    end
  end
end
