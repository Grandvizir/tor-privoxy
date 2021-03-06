require 'fileutils'
require 'erb'

tor_instances = ENV["NUM_WORKERS"].to_i
proxy_port=ENV["PROXY_PORT"].to_i
@tor_control_port = ENV["TOR_CONTROL_PORT"].to_i
current_dir = File.expand_path File.dirname(__FILE__)

#Conf
conf_dir = "#{current_dir}/config"
FileUtils.mkdir_p conf_dir
config_erb_path = "#{conf_dir}/haproxy.cfg.erb"
config_path = "#{conf_dir}/haproxy.cfg"
@port = 5566

@backends = []
tor_instances.times.each do |num|
  @backends << {:name => 'tor', :addr => '127.0.0.1', :port => proxy_port+num}
end
erb = ERB.new(File.read(config_erb_path))
IO.write(config_path, erb.result(binding))

#Log
log_dir = "#{current_dir}/log"
FileUtils.mkdir_p log_dir

God.watch do |w|
  w.name          = "haproxy-1"
  w.group         = 'haproxy'
  w.start         = "haproxy -f #{config_path}"
  w.log           = "#{log_dir}/haproxy.log"
  w.keepalive
end