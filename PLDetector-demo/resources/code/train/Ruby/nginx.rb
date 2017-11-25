namespace :deploy do
  
  after "deploy:start", "deploy:nginx_restart"
  after "deploy:restart", "deploy:nginx_restart"
  
  task :nginx_restart do
    run [
      "sudo cp #{current_path}/config/server/nginx/www.bolideapp.com /etc/nginx/sites-enabled/www.bolideapp.com",
      "sudo cp #{current_path}/config/server/nginx/live.bolideapp.com /etc/nginx/sites-enabled/live.bolideapp.com",
      "sudo /etc/init.d/nginx restart"
      ].join(" && ")
  end

end