# unicorn_rails -c /data/github/current/config/server/app/ws.bolideapp.com.rb -E production -D
 
rails_env = ENV['RACK_ENV'] || 'production'
ENV['RAILS_ENV'] = rails_env

# 4 workers and 1 master
worker_processes (rails_env == 'production' ? 2 : 1)
 
# Load rails+github.git into the master before forking workers
# for super-fast worker spawn times
preload_app true
 
# Restart any workers that haven't responded in 30 seconds
timeout 10

# Listen on a Unix data socket
if rails_env == 'production'
  stderr_path "/u/apps/bolide/current/stream_app/log/unicorn.live.stderr.log" 
  stdout_path "/u/apps/bolide/current/stream_app/log/unicorn.live.stdout.log"
  working_directory "/u/apps/bolide/current/stream_app"
  logger Logger.new("/u/apps/bolide/current/stream_app/log/unicorn.live.log", 'monthly')
  pid '/u/apps/bolide/current/stream_app/tmp/pids/live.unicorn.pid'
  listen '/u/apps/bolide/current/stream_app/tmp/sockets/live.sock', :backlog => 2048 
end
 
before_fork do |server, worker|
  ##
  # When sent a USR2, Unicorn will suffix its pidfile with .oldbin and
  # immediately start loading up a new version of itself (loaded with a new
  # version of our app). When this new Unicorn is completely loaded
  # it will begin spawning workers. The first worker spawned will check to
  # see if an .oldbin pidfile exists. If so, this means we've just booted up
  # a new Unicorn and need to tell the old one that it can now die. To do so
  # we send it a QUIT.
  #
  # Using this method we get 0 downtime deploys.
  old_pid = "/u/apps/bolide/current/stream_app/tmp/pids/live.unicorn.pid.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end
 
 
after_fork do |server, worker|
  ##
  # Unicorn master loads the app then forks off workers - because of the way
  # Unix forking works, we need to make sure we aren't using any of the parent's
  # sockets, e.g. db connection
 
  ##
  # Unicorn master is started as root, which is fine, but let's
  # drop the workers to git:git
 
  begin
    uid, gid = Process.euid, Process.egid
    user, group = 'www-data', 'www-data'
    target_uid = Etc.getpwnam(user).uid
    target_gid = Etc.getgrnam(group).gid
    worker.tmp.chown(target_uid, target_gid)
    if uid != target_uid || gid != target_gid
      Process.initgroups(user, target_gid)
      Process::GID.change_privilege(target_gid)
      Process::UID.change_privilege(target_uid)
    end
  rescue => e
    if rails_env != 'production'
      STDERR.puts "couldn't change user, oh well"
    else
      raise e
    end
  end
end

Rainbows! do
    use :EventMachine # this may also be :ThreadSpawn or :ThreadPool
    worker_connections 256
  end