require 'java'

java_import com.visionael.api.ApiFactory
java_import com.visionael.api.vnd.query.Query
java_import com.visionael.api.vfd.dto.facility.DetachedPlan
java_import com.visionael.api.vfd.dto.facility.DetachedBayline
java_import com.visionael.api.vfd.dto.equipment.DetachedDevice
java_import com.visionael.api.vfd.dto.equipment.DetachedRack

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

