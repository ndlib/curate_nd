#
# copied from https://gist.github.com/2129714
#

rails_root = ENV["RAILS_ROOT"]
working_directory rails_root
worker_processes 3
listen 8081
timeout 30

pid "#{rails_root}/tmp/pids/unicorn.pid"

stderr_path "#{rails_root}/log/unicorn.stderr.log"
stdout_path "#{rails_root}/log/unicorn.stdout.log"

Configurator::DEFAULTS[:logger].formatter = Logger::Formatter.new

preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
  Resque.redis.client.reconnect if Resque.redis
end

before_exec do |server|
  ENV["BUNDLE_GEMFILE"] = "#{rails_root}/Gemfile"
end
