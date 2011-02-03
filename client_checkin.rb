#!/usr/bin/env jruby

require 'rubygems'
require 'soap/rpc/driver'
require 'server_configuration'

URL = "http://#{HOST}:#{PORT}"

begin
	driver = SOAP::RPC::Driver.new(URL, NAMESPACE)
	 
	# Add remote sevice methods
	METHODS.each { |signature|	driver.add_method(*signature) }

	puts 'invoking check_in...'
	puts driver.CheckIn 'giuseppe', '02/03/11 12:11', 'sn123456', '3C63100-AC-C', '3C63100-AC-C', 'depot01-bay003-Utility Cabinet-001:Pos AA1'

rescue => err
   puts err.message
end

