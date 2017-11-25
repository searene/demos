require File.expand_path('../base', __FILE__)

class QWsTest < BaseStreamTest
  
  def test_create_account
    
    #check that the account is saved in memcache
    @account2 = BolideApi::Account.load_with(:_id=>ACCOUNT)
    assert_equal @account2.api_key, @account.api_key

    #check that the queue vhost for bolide as the account name
    assert @account.vhost_q.pop.match(ACCOUNT)
    
    #check that the stats are created
    assert BolideApi::MemCache.instance.get(@account.delivered_key)
    assert BolideApi::MemCache.instance.get(@account.sent_key)
    assert BolideApi::MemCache.instance.get(@account.concurrent_key)
    
    #check that it was added to #accounts
    accounts = BolideApi::MemCache.instance.get("#accounts");
    assert accounts.include?(ACCOUNT)
  end
  
  def test_create_q
    async = true
    
    after_request do |chunk|
      #check that the request returned valid data
      check_q(chunk)
    end
    
    set_headers
    
    EventMachine.run{ put "/q/#{Q1}.xml" }
  end
  
  def test_show_q
    async = true
    
    set_headers
    
    EventMachine.run do
      
      #create the q
      put "/q/#{Q1}.xml" 
    
      after_request do |chunk|
        #check that the request returned valid data
        check_q(chunk)
      end
      
      get "/q/#{Q1}.xml"
      
    end
      
  end
  
  def check_q(chunk)
    xml = Nokogiri::XML(chunk)
  
    name = xml.at_css('q')[:id]
    assert_equal Q1, name

    token = xml.at_css('q token').content
    assert token

    expire_on = xml.at_css('q expire_on').content
    assert expire_on
    assert DateTime.parse(expire_on) > DateTime.now

    msg_count = xml.at_css('q msg_count').content
    assert msg_count

    #now check that the q was really created
    @account = BolideApi::Account.load_with(:_id=>ACCOUNT)
    assert @account.qs.include?(Q1)
  
    EM.stop
  end
  
end
