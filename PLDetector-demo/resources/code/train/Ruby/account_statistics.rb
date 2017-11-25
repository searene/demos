module BolideApi
  
  module AccountStatistics
      
    #accessors
    
    def sent
      Integer(MemCache.instance.get(sent_key, true))
    end
    
    def delivered
      Integer(MemCache.instance.get(delivered_key, true))
    end
    
    def concurrent
      Integer(MemCache.instance.get(concurrent_key, true))
    end
      
    #update with atomic methods
    def up_sent
      MemCache.instance.increment sent_key
      if(_id != "bolide")
        
        gsent = global_sent
        MemCache.instance.increment global_sent_key
        
        msg = Msg.new(Account.load_with(:_id=>"bolide"))
        msg.body = gsent
        msg.select = ".*"
        msg.send_msg
        
      end
    end

    def up_delivered
      MemCache.instance.increment delivered_key
    end

    def up_concurrent
      MemCache.instance.increment concurrent_key
    end

    def down_concurrent
      MemCache.instance.decrement concurrent_key
    end
    
    def global_sent
      if ENV["RAILS_ENV"] != "test"
        MemCache.instance.memcache.fetch(global_sent_key, 0, true) do
          0
        end
      end
    end
  
    def global_sent_key
      "#bolide/global/live/sent"
    end
  
  #keys
    def concurrent_key
      "#" + key + '/live/concurrent'
    end

    def sent_key
      "#" + key + '/live/sent'
    end

    def delivered_key
      "#" + key + '/live/delivered'
    end
    
  end
  
end