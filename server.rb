#!/usr/bin/env jruby

require 'java'
require 'rubygems'
require 'soap/rpc/standaloneServer'
require 'server_configuration'

java_import com.visionael.api.ApiFactory
java_import com.visionael.api.vnd.query.Query
java_import com.visionael.api.vfd.dto.equipment.DetachedDevice
java_import com.visionael.api.vfd.dto.equipment.DetachedRack
java_import com.visionael.api.vfd.dto.facility.DetachedBayline
java_import com.visionael.api.vfd.dto.facility.DetachedPlan
java_import com.visionael.api.dto.DetachedEntity
java_import com.visionael.api.vfd.library.LibrarySearchFilter

class ApplicationError < StandardError 
end

class AricentServer < SOAP::RPC::StandaloneServer
	def initialize(*args)
		super
		@log.level = Logger::Severity::DEBUG
		METHODS.each { |signature|	add_method(self, *signature) }
		@af = ApiFactory.new VISHOST, VISPORT
		@fa = @af.getFacilityApi
		@la = @af.getLibraryApi
	end

	###################################################################
	# webservice methods
	###################################################################

	# test method that invoke nmr10 server to search a device
	# input		: name:string
	# output	: OK:device_name || ER:NOT FOUND || EX:exception message
	def FindDevice(name)
		begin
			q = Query.find(DetachedDevice.java_class).matching('name',name)
			fr = @fa.find q
			dev = fr.getFirst
			if !dev.nil?
				"OK:#{dev.getName}"
			else
				raise ApplicationError, "NOT FOUND"
			end
		rescue ApplicationError => e
			"ER:#{e.message}"
		rescue Exception => e
			"EX:#{e.message}"
		end
	end

	# CheckIn 
  # user_id                 : userid of the operator
  # date                    : date of the operation
  # serial_number           : spare serial number
  # part_number             : part number used to lookup the spec in the library
  # vendor_part_number      : ? same as part number 
  # depot_string            : colon separated value of the spare container e.g. 'Spare Depot Plan:Bayline001:Rack25'
  def CheckIn(user_id, date, serial_number, part_number, vendor_part_number, depot_string)
	  begin
	    #parent = find_entity_by_path depot_string
	    depot_string = depot_string.split(':').reverse
      position = depot_string.delete_at(0)
	    parent = find_depot_placement depot_string.first
	    raise ApplicationError, "Depot placement not found" if parent.nil?
      
      spare = add_spare part_number

      #set custom attributes
      mixin = get_mixin spare, 'Spares'
      mixin.put 'Condition', 'CheckIn'
      mixin.put 'Part number', part_number
      mixin.put 'Serial number', serial_number
      mixin.put 'Last op. user id', user_id
      mixin.put 'Last op. date', date
      mixin.put 'Vendor part number', vendor_part_number
      mixin.put 'Position', position
      @fa.saveMixinData(spare, mixin)		

      #spare placement
      placement = nil
      if parent.java_kind_of? DetachedRack
        placement = @fa.addChassisToRack(spare, parent, 100);
      elsif parent.java_kind_of? DetachedPlan
        placement = @fa.addItemToPlan(spare, parent, 60, 60, 0);
      elsif parent.java_kind_of? DetachedBayline
        placement = @fa.addItemToBayline(spare, parent, 4);
      end
      raise ApplicationError ,"Spare not positioned - bad spare placement" if placement.nil?

		  "SUCCESS"
	  rescue ApplicationError => e
		  "FAILURE: APPLICATION ERROR - #{e.message}"
	  rescue Exception => e
		  "FAILURE: EXCEPTION - #{e.message}"
	  end
  end

	# stub method, echoes params back
	def CheckOut(user_id, date, serial_number, part_number, vendor_part_number, depot_string, asset_tag, facebook_part_number, failed_part_rma)
		"OK:#{user_id},#{date},#{serial_number},#{part_number},#{vendor_part_number},#{depot_string},#{asset_tag},#{facebook_part_number},#{failed_part_rma}"
	end

	# stub method, echoes params back
	def CaptureFailedPart(user_id, date, serial_number, part_number, vendor_part_number, depot_string, asset_tag, facebook_part_number, rma, parent_serial_number, parent_asset_tag)
		"OK:#{user_id},#{date},#{serial_number},#{part_number},#{vendor_part_number},#{depot_string},#{asset_tag},#{facebook_part_number},#{rma},#{parent_serial_number},#{parent_asset_tag}"
	end	

	# stub method, echoes params back
	def RMA(user_id, date, serial_number, part_number, vendor_part_number, depot_string, asset_tag, facebook_part_number, rma, carrier_name, carrier_traking_number)
		"OK:#{user_id},#{date},#{serial_number},#{part_number},#{vendor_part_number},#{depot_string},#{asset_tag},#{facebook_part_number},#{rma},#{carrier_name},#{carrier_traking_number}"
	end

	###################################################################
	# private methods
	###################################################################
	private

  def get_model(search_filter)
    begin
      spec_description_key = @la.findSpecDescriptions(search_filter)[0]
      @fa.getModelFromLibraryKey(spec_description_key)
    rescue Exception => e
      return nil
    end
  end

  def get_mixin entity, mixin_name
    mixin = @fa.find(entity, Query.findRelatives("mixin:#{mixin_name}")).getRelatedEntities(entity, "mixin:#{mixin_name}").iterator.next
  end

  def find_entity_by_path entity_path
    @fa.find(Query.find(DetachedRack.java_class).matching('name', entity_path)).getFirst
  end

  def find_depot_placement name
    placement = nil
    [
      DetachedRack.java_class,
      DetachedPlan.java_class,
      DetachedBayline.java_class    
    ].each { |klass| 
      placement = @fa.find(Query.find(klass).matching('name', name)).getFirst
      break if !placement.nil?
    }
    placement
  end

  def add_spare part_number
    #find the spare chassis used to model all the spare parts
    spare_model = get_model LibrarySearchFilter.createChassisFilter(SPAREDEVSPEC)
    raise ApplicationError ,"SparePart model not found" if spare_model.nil?    

    #find equipment model. here we are trying on several types since we know only the part_no
    equip_model = nil
    [
      LibrarySearchFilter.createChassisFilter(part_number),
      LibrarySearchFilter.createCardFilter(part_number),
      LibrarySearchFilter.createAdapterFilter(part_number),
      LibrarySearchFilter.createPatchPanelFilter(part_number)
    ].each { |filter| 
      equip_model = get_model filter
      break if !equip_model.nil?
    }
    raise ApplicationError ,"Equipment model not found" if equip_model.nil?    

    spare = @fa.createChassis(spare_model, "#{equip_model.getName} - spare equipment")
    raise ApplicationError ,"Spare not created" if spare.nil?

    mixin = get_mixin spare, 'Spares'
    mixin.put 'Description', equip_model.getDescription
    @fa.saveMixinData(spare, mixin)		

    spare
  end

end

begin
	server = AricentServer.new("AricentServer", NAMESPACE, '0.0.0.0', PORT)
  trap(:INT){ server.shutdown }
  server.start
rescue => err
  puts err.message
end

