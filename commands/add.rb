#Basic ping command for now
@bot.register_application_command(:add, "Add a domain", server_id: ENV['GUILD_ID'])

id = Random.rand(1..9999)

@bot.application_command(:add) do |event|
  id = Random.rand(1..9999)
  event.show_modal(title: 'Add a domain', custom_id: "add_domain_#{id}") do |modal|
    modal.row do |row|
      row.text_input(
        style: :short,
        custom_id: "domain_input",
        label: "Domain",
        required: true,
        placeholder: "example.com"
      )
    end
  end
  def verify_domain(domain, event)
    if isPointedToServer(domain) == false
      event.send_message(content: "Domain is not pointed to the server!", ephemeral: true)
      event.send_message(content: "If you are using Cloudflare, make sure the proxy is disabled!", ephemeral: true)
    else 
      if doesDomainExist(domain) == true
        event.send_message(content: "Domain already exists!", ephemeral: true)
      else
        addDomain(domain, event.user.id)
        event.send_message(content: "Added #{domain} to the server!", ephemeral: true)
      end
    end
  end
  @bot.modal_submit custom_id: "add_domain_#{id}" do |event|
    domain = event.value('domain_input')
    event.defer
    if isDomain(domain) == false
      event.send_message(content: "Invalid domain!", ephemeral: true)
    else
      verify_domain(domain, event)
    end
  end
end
