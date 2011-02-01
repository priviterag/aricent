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
	puts driver.CheckIn 'user_id', 'date', 'serial_number', 'part_number', 'vendor_part_number', 'depot_string', 'asset_tag', 'facebook_part_number'

	puts 'invoking check_out...'
	puts 	driver.CheckOut 'user_id', 'date', 'serial_number', 'part_number', 'vendor_part_number', 'depot_string', 'asset_tag', 'facebook_part_number', 'failed_part_rma'

	puts 'invoking capture_failed_part...'
	puts 	driver.CaptureFailedPart 'user_id', 'date', 'serial_number', 'part_number', 'vendor_part_number', 'depot_string', 'asset_tag', 'facebook_part_number', 'rma', 'parent_serial_number', 'parent_asset_tag'   

	puts 'invoking rma...'
	puts 	driver.RMA 'user_id', 'date', 'serial_number', 'part_number', 'vendor_part_number', 'depot_string', 'asset_tag', 'facebook_part_number', 'rma', 'carrier_name', 'carrier_traking_number'
rescue => err
   puts err.message
end

