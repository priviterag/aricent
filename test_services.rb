#!/usr/bin/env jruby

require 'rubygems'
require 'soap/rpc/driver'
require 'server_configuration'

URL = "http://#{HOST}:#{PORT}"

begin
	driver = SOAP::RPC::Driver.new(URL, NAMESPACE)
	 
	# Add remote sevice methods
	METHODS.each { |signature|	driver.add_method(*signature) }

  puts "checkin spare part  - serial_number sn111:#{driver.CheckIn('giuseppe', '02/03/11 12:11', 'sn111', '3C63100-AC-C', '3C63100-AC-C', 'depot01-bay003-Utility Cabinet-001:AA-1', 'at111', 'fb111')}" 
  puts "checkin spare part  - serial_number sn222:#{driver.CheckIn('giuseppe', '02/03/11 12:11', 'sn222', '3C63100-AC-C', '3C63100-AC-C', 'depot01-bay003-Utility Cabinet-001:AA-1', 'at222', 'fb222')}" 
  puts "checkout spare part - serial_number sn111:#{driver.CheckOut('giuseppe', '02/03/11 12:11', 'sn111', '3C63100-AC-C', '3C63100-AC-C', 'depot01-bay003-Utility Cabinet-001:AA-1')}" 
  puts "capture failed part - serial_number sn111:#{driver.CaptureFailedPart('giuseppe', '02/03/11 12:11', 'sn111', '3C63100-AC-C', '3C63100-AC-C', 'depot01-bay003-Utility Cabinet-001:AA-3', 'at111', 'fb111', 'rma111', 'psn123', 'pas123')}" 
  puts "checkout spare part - serial_number sn222:#{driver.CheckOut('giuseppe', '02/03/11 12:11', 'sn222', '3C63100-AC-C', '3C63100-AC-C', 'depot01-bay003-Utility Cabinet-001:AA-1')}" 
  puts "rma spare part      - serial_number sn111:#{driver.RMA('giuseppe', '02/03/11 12:11', 'sn111', '3C63100-AC-C', '3C63100-AC-C', 'depot01-bay003-Utility Cabinet-001:AA-3', 'at111', 'fb111', 'rma111', 'UPS', 'UPS-tn123456')}" 
  
rescue => err
   puts err.message
end

