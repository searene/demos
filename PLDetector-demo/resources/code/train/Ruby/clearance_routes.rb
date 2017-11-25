ActionController::Routing::Routes.draw do |map|
  map.resources :passwords,
    :controller => 'clearance/passwords',
    :only       => [:new, :create]

  map.resource  :session,
    :controller => 'clearance/sessions',
    :only       => [:new, :create, :destroy]

  map.resources :users, :controller => 'clearance/users' do |users|
    users.resource :password,
      :controller => 'clearance/passwords',
      :only       => [:create, :edit, :update]

    users.resource :confirmation,
      :controller => 'clearance/confirmations',
      :only       => [:new, :create]
  end

  map.sign_up  'sign-up',
    :controller => 'clearance/users',
    :action     => 'new'
  map.sign_in  'sign-in',
    :controller => 'clearance/sessions',
    :action     => 'new'
  map.sign_out 'sign-out',
    :controller => 'clearance/sessions',
    :action     => 'destroy',
    :method     => :delete
  map.forgot_password 'forgot-password',
    :controller => 'clearance/passwords',
    :action     => 'new'
end
