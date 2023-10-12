require "./app"

if (memcached_servers = ENV["MEMCACHEDCLOUD_SERVERS"])
  require "dalli"

  configure do
    options = {
      username: ENV["MEMCACHEDCLOUD_USERNAME"],
      password: ENV["MEMCACHEDCLOUD_PASSWORD"]
    }

    set :cache, Dalli::Client.new(memcached_servers, options)
  end
end

run Sinatra::Application
