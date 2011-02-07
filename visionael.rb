require 'java'

java_import com.visionael.api.ApiFactory
java_import com.visionael.api.vnd.query.Query
java_import com.visionael.api.vfd.dto.facility.DetachedPlan
java_import com.visionael.api.vfd.dto.facility.DetachedBayline
java_import com.visionael.api.vfd.dto.equipment.DetachedChassis
java_import com.visionael.api.vfd.dto.equipment.DetachedDevice
java_import com.visionael.api.vfd.dto.equipment.DetachedCard
java_import com.visionael.api.vfd.dto.equipment.DetachedRack
java_import com.visionael.api.vfd.library.LibrarySearchFilter

class ApplicationError < StandardError ;end
 
def visionael_init(host, port)
  $api_factory = ApiFactory.new host, port
  $facility_api = $api_factory.getFacilityApi
  $library_api = $api_factory.getLibraryApi
end

def find_entity_by_name(klass, name)
  $facility_api.find(Query.find(klass).matching('name',name)).getFirst    
end

def find_entities_by_mixin klass, mixin, conditions
  condition = conditions.delete_at 0
  $facility_api.find(
    Query.find(klass).having(
      conditions.inject(Query.findRelatives("mixin:#{mixin}").matching(condition[0], condition[1])) { |query, condition|  
        query = query.and().matching(condition[0], condition[1])
      }
    )
  ).getRootEntities
end

def get_model_from_library(search_filter)
  begin
    spec_description_key = $library_api.findSpecDescriptions(search_filter)[0]
    $facility_api.getModelFromLibraryKey(spec_description_key)
  rescue Exception => e
    nil
  end
end

def get_chassis_slots chassis
  model = get_device_model(chassis)
  slots = get_related_entities(model, 'slots')
end

def get_device_model device
  get_related_entities(device, 'model').iterator.next
end

def get_related_entities entity , relationship
  $facility_api.find(entity,Query.findRelatives(relationship)).getRelatedEntities(entity,relationship)
end

def get_mixin_data entity, mixin_name
  mixin = $facility_api.getMixinData(entity, mixin_name)
end



