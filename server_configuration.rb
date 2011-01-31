NAMESPACE = 'urn:AricentServer'
HOST = 'localhost' # webservice host
PORT = 2000 # webservice port
VISHOST = HOST # Visionael NRM10 server
VISPORT = 3700 # Visionael NRM10 server port

METHODS=[
	%w(find_device name),
	%w(check_in user_id date serial_number part_number vendor_part_number depot_string asset_tag facebook_part_number),
	%w(check_out user_id date serial_number part_number vendor_part_number depot_string asset_tag facebook_part_number failed_part_rma),
	%w(capture_failed_part user_id date serial_number part_number vendor_part_number depot_string asset_tag facebook_part_number rma parent_serial_number parent_asset_tag),
	%w(rma user_id date serial_number part_number vendor_part_number depot_string asset_tag facebook_part_number rma carrier_name carrier_traking_number)
]


