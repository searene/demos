set :application, "bolide"
set :repository,  "/bolide"

set :user, "juggy"

set :repository, "git@github.com:juggy/bolide.git"
set :branch, "master"

role :web, "173.203.201.158"                          # Your HTTP server, Apache/etc
role :app, "173.203.201.158"                          # This may be the same as your `Web` server
role :mcdb, "173.203.201.158"
role :rabbit, "173.203.201.158"

load 'config/recipes/fast_git_deploy'
load 'config/recipes/apps'
load 'config/recipes/nginx'

