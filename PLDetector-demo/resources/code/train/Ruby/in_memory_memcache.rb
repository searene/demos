require 'singleton'

module BolideApi
  
  class InMemoryMemCache < Hash
    def get(key, raw = false)
      self[key]
    end
    
    def set(key, value, expire = 0, raw = false)
      self[key] = value
    end
    
    def incr(key)
      v = self[key];
      v = 0 if v.nil?
      self[key] = v + 1
    end
    
    def decr(key)
      v = self[key];
      v = 1 if v.nil?
      self[key] = v - 1
    end
  end
end