Rainbows! do
  name = 'transit'
  use :ThreadPool
  client_max_body_size nil # This is set in nginx
  # keepalive_timeout 1

  case ENV['RACK_ENV'].to_sym
  when :development
    listen 9292
  when :production
    listen 10000
    worker_processes 6
    worker_connections 32
    timeout 30
#    listen "unix:/var/run/geoloqi/#{name}.sock", :backlog => 2048
    pid "/tmp/#{name}.pid"
    stderr_path "/tmp/#{name}.log"
    stdout_path "/tmp/#{name}.log"

    ###
    # Hardcore performance tweaks, described here: https://github.com/blog/517-unicorn
    ###

    # This loads the app in master, and then forks workers. Kill with USR2 and it will do a graceful restart using the block proceeding.
    preload_app true

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

      old_pid = "/tmp/#{name}.pid.oldbin"
      if File.exists?(old_pid) && server.pid != old_pid
        begin
          Process.kill("QUIT", File.read(old_pid).to_i)
        rescue Errno::ENOENT, Errno::ESRCH
          # someone else did our job for us
        end
      end
    end
  end
end
