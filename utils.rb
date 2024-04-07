require 'resolv'
require 'sequel'
def isDomain(domain)
  #domain can have no http or https, so we need to check for that
  domain = domain.gsub("http://", "").gsub("https://", "")
  #check if domain is valid
  if domain =~ /([-_a-zA-Z0-9]+\.[a-z]{1,3})\Z/
    return true
  else
    return false
  end
end

def isPointedToServer(domain)
  begin
    ip = Resolv.getaddress(domain)
    if ip == ENV['SERVER_IP']
      return true
    else
      return false
    end
  rescue Resolv::ResolvError
    return false
  end
end 

def initDB 
  db = Sequel.connect('sqlite://byod.db')
  if db.table_exists?(:domains) == false
    puts "Creating table as it does not exist".yellow
    db.create_table :domains do
      primary_key :id
      String :domain
      String :user
    end
  end
end

def doesDomainExist(domain)
  db = Sequel.connect('sqlite://byod.db')
  if db[:domains].where(domain: domain).count > 0
    return true
  else
    return false
  end
end

def addDomain(domain, user)
  db = Sequel.connect('sqlite://byod.db')
  db[:domains].insert(domain: domain, user: user)
end

def deleteDomain(domain)
  db = Sequel.connect('sqlite://byod.db')
  db[:domains].where(domain: domain).delete
end

def findAllDomainsToUser(user)
  db = Sequel.connect('sqlite://byod.db')
  domains = db[:domains].where(user: user)
  return domains
end
