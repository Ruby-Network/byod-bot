require 'sinatra'
require './utils.rb'
get '/domainCheck/:domain?' do 
  query = params[:domain]
  if query.nil?
    return "No domain provided"
  else
    if doesDomainExist(query) == true
      status 200
      return "Domain exists"
    else
      status 404
      return "Domain does not exist"
    end
  end
end
