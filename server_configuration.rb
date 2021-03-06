NAMESPACE = 'http://mysite.org/wsdl/InventoryMgmt'
HOST = 'localhost' # webservice host
PORT = 2000 # webservice port
VISHOST = HOST # Visionael NRM10 server
VISPORT = 3700 # Visionael NRM10 server port
SPAREDEVSPEC = 'SparePart'

METHODS=[
	%w(FindDevice name),
	%w(CheckIn user_id date serial_number part_number vendor_part_number depot_string asset_tag facebook_part_number),
	%w(CheckOut user_id date serial_number part_number vendor_part_number depot_string),
	%w(CaptureFailedPart user_id date serial_number part_number vendor_part_number depot_string asset_tag facebook_part_number rma parent_serial_number parent_asset_tag),
	%w(RMA user_id date serial_number part_number vendor_part_number depot_string asset_tag facebook_part_number rma carrier_name carrier_tracking_number)
]


