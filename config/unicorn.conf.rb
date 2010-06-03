rails_env = ENV['RAILS_ENV'] || 'production'
worker_processes (rails_env == 'production' ? 16 : 4)
preload_app true
timeout 30

if GC.respond_to?(:copy_on_write_friendly=)
  GC.copy_on_write_friendly = true
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection
end
