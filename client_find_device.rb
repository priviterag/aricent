#!/usr/bin/env jruby

require 'rubygems'
require 'soap/rpc/driver'
require 'server_configuration'

URL = "http://#{HOST}:#{PORT}"

begin
	if ARGV.count == 0
		puts 'usage: client_find_device.rb device_name'
	else
		driver = SOAP::RPC::Driver.new(URL, NAMESPACE)
		 
		# Add remote sevice methods
		METHODS.each { |signature|	driver.add_method(*signature) }

		# Call remote service methods
		# e.g. 'Cisco 12410 Router'
		puts "searching: #{ARGV[0]}"
		puts driver.find_device ARGV[0]
	end
rescue => err
   puts err.message
end

