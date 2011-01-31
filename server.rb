#!/usr/bin/env jruby

require 'java'
require 'rubygems'
require 'soap/rpc/standaloneServer'
require 'server_configuration'

java_import com.visionael.api.ApiFactory
java_import com.visionael.api.vnd.query.Query
java_import com.visionael.api.vfd.dto.equipment.DetachedDevice

class AricentServer < SOAP::RPC::StandaloneServer
	def initialize(*args)
		super
		@af = ApiFactory.new VISHOST, VISPORT
		@fa = @af.getFacilityApi
		@log.level = Logger::Severity::DEBUG
		METHODS.each { |signature|	add_method(self, *signature) }
	end

	###################################################################
	# webservice methods
	###################################################################

	# test method that invoke nmr10 server to search a device
	# input		: name:string
	# output	: OK:device_name || KO:NOT FOUND || EX:exception message
	def find_device(name)
		begin
			q = Query.find(DetachedDevice.java_class).matching('name',name)
			fr = @fa.find q
			dev = fr.getFirst
			if !dev.nil?
				"OK:#{dev.getName}"
			else
				'KO:NOT FOUND'
			end
		rescue Exception => e
			"EX:#{e.message}"
		end
	end

	# stub method, echoes params back
	def check_in(user_id, date, serial_number, part_number, vendor_part_number, depot_string, asset_tag, facebook_part_number)
		"OK:#{user_id},#{date},#{serial_number},#{part_number},#{vendor_part_number},#{depot_string},#{asset_tag},#{facebook_part_number}"
	end

	# stub method, echoes params back
	def check_out(user_id, date, serial_number, part_number, vendor_part_number, depot_string, asset_tag, facebook_part_number, failed_part_rma)
		"OK:#{user_id},#{date},#{serial_number},#{part_number},#{vendor_part_number},#{depot_string},#{asset_tag},#{facebook_part_number},#{failed_part_rma}"
	end

	# stub method, echoes params back
	def capture_failed_part(user_id, date, serial_number, part_number, vendor_part_number, depot_string, asset_tag, facebook_part_number, rma, parent_serial_number, parent_asset_tag)
		"OK:#{user_id},#{date},#{serial_number},#{part_number},#{vendor_part_number},#{depot_string},#{asset_tag},#{facebook_part_number},#{rma},#{parent_serial_number},#{parent_asset_tag}"
	end	

	# stub method, echoes params back
	def rma(user_id, date, serial_number, part_number, vendor_part_number, depot_string, asset_tag, facebook_part_number, rma, carrier_name, carrier_traking_number)
		"OK:#{user_id},#{date},#{serial_number},#{part_number},#{vendor_part_number},#{depot_string},#{asset_tag},#{facebook_part_number},#{rma},#{carrier_name},#{carrier_traking_number}"
	end
end

begin
	server = AricentServer.new("AricentServer", NAMESPACE, '0.0.0.0', PORT)
  trap(:INT){ server.shutdown }
  server.start
rescue => err
  puts err.message
end

