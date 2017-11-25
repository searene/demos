require 'spec_helper'
require 'digest/md5'

def headers(account, api_key)
  now = DateTime.now.to_s
  auth_key_prev = 'Account:' + account + '\n' + 'Api-Key:' + api_key + '\n' + 'X-Bol-Date:' + now
  auth_key = Digest::MD5.hexdigest(auth_key_prev)
  {'HTTP_X_BOL_DATE'=>now, 'HTTP_X_BOL_AUTHENTICATION'=>account + ':' + auth_key}
end

describe QsController do
  
  integrate_views

  #should set the request headers
  before :each do
    @request.env['HTTP_ACCEPT'] = 'application/xml'
    @request.set_headers headers('test_account', '1234567890')
  end
  

  it "should not authenticate with a wrong account" do
    get 'index'
    response.should_not be_success
  end
  
  
  it "should authenticate with a valid account" do
    account = BolideApi::Account.load_with(:_id=>'test_account', :api_key=>'1234567890')
    account.save
    
    get 'index'
    response.should be_success
  end
  
  it 'should list the empty qs for an account' do
    get 'index'
    response.should be_success
    response.should have_tag 'qs'
  end
  
  it "should route to the q controller on put" do 
    params_from(:put, "/q/qname").should == 
              {:controller => "qs", :action => "update", :id=>'qname'}
  end
  
  it "should create a non existing q" do 
    put 'update', {:id=>'testq'}, {:format =>'xml'}
    response.should be_success
    response.should render_template('show.xml.builder')
  end
end
