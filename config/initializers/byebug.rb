if Rails.env.development? && !defined?(Rails::Console)
  require 'byebug/core'
  #Byebug.wait_connection = true
  port = ENV.fetch("BYEBUG_SERVER_PORT", 9876).to_i
  begin
    print "Starting byebug server for remote debugging on port #{port}\n"
    Byebug.start_server 'localhost', port
  rescue Errno::EADDRNOTAVAIL
    puts "Port #{port} already in use. It could be byebug"
  end
end
