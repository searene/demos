require 'singleton'

module BolideApi
  class MemCache
    include Singleton
    
    attr_accessor :memcache
    
    def initialize
      if ENV['RAILS_ENV'] == 'test'
        @memcache = InMemoryMemCache.new
      else
        opts = MemCacheDbConnection.options
        @memcache = MemCacheDb.new(MemCacheDbConnection.servers, opts ? opts : {})   
      end
    end
    
    def get(key, raw = false)
      value = memcache.get(key, raw)
      if value.nil? 
        yield if block_given?
      else 
        value
      end
    end
   
    def increment(key)
      memcache.incr(key)
    end
    
    def decrement(key)
      memcache.decr(key)
    end
    
    def set(key, value, expire = 0, raw = false)
      memcache.set(key, value, expire, raw)
    end
    
  end
end