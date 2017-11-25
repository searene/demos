
module BolideApi
  class InvalidAccountError < Exception
  end
  
  class Q < Base
    
    validates_presence_of :_id, :token, :expire_on
    validates_true_for :account, :logic => lambda {!@account.nil?} 
    before_validation do
      generate_token
      reset_expiration
    end
    
    attr_accessor :_id, :account, :token, :expire_on, :account_id
   
    def msg_count
      0
      #mq.message_count
    end
    
    def read_msg
      msg = mq.pop
      @account.up_delivered if msg
      msg
    end
    
    def send_msg(m)
      @account.up_sent
      mq.publish(m)
    end
  
    def delete_mq
      mq.delete
    end
  
    def mq
      @mq = @account.vhost.queue(_id, {:exclusive=>false, :durable=>true})
    end

    def key
      (@account_id || @account._id) + '_' + @_id
    end
    
    def valid_token?(t)
      @token == t
    end
    
    def marshal_dump
      {
        :id=>@_id,
        :account_id=>@account._id,
        :saved=>@saved,
        :token=>@token,
        :expire_on=>@expire_on
      }
    end

    def marshal_load(data)
      @_id = data[:id]
      @account = Account.load_with(:_id=>data[:account_id])
      @saved = data[:saved]
      @token = data[:token]
      @expire_on = data[:expire_on]
    end
    
    def account
      unless @account
        @account = Account::load_with(:_id=>@account_id) 
        raise InvalidAccountError unless @account.saved
      end
      @account
    end
    
    def after_initialize
      q_uniqueness
    end
    
    def after_create
      @account.qs << _id
      @account.save
    end
    
    def reset_expiration
      @expire_on = 5.minutes.from_now.to_datetime
    end

    private
    
    def q_uniqueness
      raise UniquenessError if @account && @account.qs.include?(@_id) 
    end
    
    def generate_token
      @token = UUID.generate
    end
  
  end

end