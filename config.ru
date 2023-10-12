require "dalli"
require "rack/cache"

require "./app"

if ENV["MEMCACHEDCLOUD_SERVERS"]
  memcached_username = ENV.fetch("MEMCACHEDCLOUD_USERNAME")
  memcached_password = ENV.fetch("MEMCACHEDCLOUD_PASSWORD")
  memcached_servers = ENV.fetch("MEMCACHEDCLOUD_SERVERS")

  metastore_url = "memcached://#{memcached_username}:#{memcached_password}@#{memcached_servers}/meta"
  entitystore_url = "memcached://#{memcached_username}:#{memcached_password}@#{memcached_servers}/body"

  use Rack::Cache,
    verbose: true,
    metastore: metastore_url,
    entitystore: entitystore_url
end

run Sinatra::Application
