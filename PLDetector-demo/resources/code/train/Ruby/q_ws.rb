require 'cramp'
require 'cramp/controller'

class QWsController < BaseWsController
  
  def index
    @qs = @account.qs
    xml = Nokogiri::XML::Builder.new do |xml|
      xml.qs :account=>@account._id do
        @qs.each do |q|
          xml.q :id=>q._id do 
      			xml.msg_count q.msg_count
      			xml.token q.token
      			xml.expire_on q.expire_on
      		end
        end
      end
    end
    render [xml.to_xml.to_s]
  end
  
  def render_q(q)
    xml = Nokogiri::XML::Builder.new do |xml|
      xml.q :id=>q._id do 
      	xml.msg_count q.msg_count
      	xml.token q.token
      	xml.expire_on q.expire_on
      end
    end
    render [xml.to_xml.to_s]
  end
  
  def show
    @q = BolideApi::Q.load_with(:_id=>params[:id], :account=>@account )
    raise 'Invalid Queue' unless @q.saved
    render_q(@q) 
  end
  
  def update
    #try to find the q first
    @q = BolideApi::Q.load_with(:_id=>params[:id], :account=>@account)
    #save will update the expire on
    if @q.save
      render_q(@q) 
    else
      raise @q.errors.full_messages.join(', ')
    end
  end
  
  add_transaction_tracer :index, :category => :rack, :name => 'qi_stream'
  add_transaction_tracer :show, :category => :rack, :name => 'qs_stream'
  add_transaction_tracer :update, :category => :rack, :name => 'qp_stream'
end
