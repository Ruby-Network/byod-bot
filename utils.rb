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

def defineDBVars()
  host = ENV['DB_HOST']
  user = ENV['DB_USER']
  password = ENV['DB_PASSWORD']
  database = ENV['DB_DATABASE']
  return host, user, password, database
end

def connectDB
  if ENV['DATABASE'] == "sqlite"
    db = Sequel.connect('sqlite://byod.db')
  else
    host, user, password, database = defineDBVars()
    db = Sequel.postgres(host: host, user: user, password: password, database: database)
  end
  return db
end

def initDB 
  db = connectDB()
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
  db = connectDB()
  if db[:domains].where(domain: domain).count > 0
    return true
  else
    return false
  end
end

def addDomain(domain, user)
  db = connectDB()
  db[:domains].insert(domain: domain, user: user)
end

def deleteDomain(domain)
  db = connectDB()
  begin
    #string domain 
    domain = domain.to_s
    db[:domains].where(domain: domain).delete
  rescue Sequel::DatabaseError
    return 0
  end
end

def findAllDomainsToUser(user)
  db = connectDB()
  begin
    user = user.to_s
    domains = db[:domains].where(user: user)
    return domains
  rescue Sequel::DatabaseError
    return 0
  end
end
