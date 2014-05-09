require 'iron_cache'

def get(key)
  JSON.parse cache.get(key).value
end

def put(key, o)
  cache.put key, o.to_json
end

def cache
  @client ||= IronCache::Client.new

  # Get a Cache object
  @cache ||= @client.cache("my_cache")
end
