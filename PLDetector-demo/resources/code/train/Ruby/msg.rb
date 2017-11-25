require 'validatable'
class Msg 
  include Validatable
  attr_accessor :qs, :select, :body, :account, :warnings
  validates_presence_of :body, :select
  validates_true_for :select, :message=>"Select or queues not specified", :logic=>lambda{ !qs.empty? || select }
  validates_true_for :qs, :logic=>lambda{ !qs.empty? || select }
  
  def initialize(account)
    @account = account
    @warnings = []
  end
  
  def send_msg
    return false unless valid?
    
    dqs = determine_queues
    dqs = validate_queues(dqs)
    if dqs.empty?
      warnings << "Selection or queues not matching any active queues"
      return false
    end
    
    #send msg to the different queues
    dqs.each do |q|
      begin
        q.send_msg(body)
      rescue 
        warnings << "Failed publishing msg to queue " + q._id
      end
    end
  end
  
  private
  
  def validate_queues(dqs)
    dqs.collect! do |q|
      Q.load_with(:_id=>q, :account=>account)
    end
    dqs.select do |q|
      warnings << "Queue " + q._id + " is invalid" if !q.saved
      warnings << "Queue " + q._id + " is expired" if q.saved && q.expire_on && q.expire_on < DateTime.now
      q.saved && q.expire_on && q.expire_on > DateTime.now
    end
  end
  
  def determine_queues
    if select
      #check selection
      account.qs.select do |q|
        q.match(select)
      end
    else
      #check matching queue with account
      qs & account.qs
    end
  end
end
