class View::BaseController < ApplicationController
  before_filter :verify_admin, :only=>[:board]
  layout 'public'

  def index
    if !signed_in?
      redirect_to what_url
      return
    end
  end
  
  def board
    @users = User.find(:all)
  end

  def what
    @user = ::User.new(params[:user])
  end
  
  def how
    @user = ::User.new(params[:user])
  end
  
  def api
    @user = ::User.new(params[:user])
  end

  private
  
 
  def verify_admin
    if !signed_in? || current_user.email != "julien.guimont@gmail.com"
      redirect_to root_url
    end
  end

end
