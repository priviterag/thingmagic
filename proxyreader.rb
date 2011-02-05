require 'visionael'
require 'configuration'
java_import com.thingmagic.Reader

#this tags are used by the simulation
class TagReadData
  def initialize tag
    @tag=tag
  end
  
  def epcString
    @tag
  end
  
  def getTime
    Time.now
  end
end
TAGS = [
  TagReadData.new('rfid1'),
  TagReadData.new('rfid2'),
  TagReadData.new('rfid3'),
  TagReadData.new('rfid4'),
  TagReadData.new('rfid5'),
  TagReadData.new('rfid6')
]
#end of simulation data

#one object for each physical RFID reader
class ProxyReader
  attr_reader :initialized
  @@simulated = true #poll real reader
  
  def name
    "#{@reader_url}@#{@parent_entity_name}"
  end
  
  def initialize(parent_entity_name, reader_url)
    @initialized = false
    @parent = nil
	  @parent_entity_name = parent_entity_name
	  @reader_url = reader_url

    configure_containers #configure the virtual chassis container        
    @initialized = initialize_astra_reader #initialize the astra reader    
  end
  
  #proxy read
  def read duration
    if !@@simulated
      @reader.read(duration);
    else
      sleep(2+rand(10))
      [TAGS[rand(3)],TAGS[3+rand(3)]]
    end
  end
  
  def process_tag tag
    result = find_entities_by_mixin(DetachedChassis.java_class, 'ThingMagic', [['RFID tag',tag]])
    result = find_entities_by_mixin(DetachedCard.java_class, 'ThingMagic', [['RFID tag',tag]]) if result.empty?
    raise ApplicationError, "process_tag(#{tag}) - equipment not found" if result.empty?
    equipment = result.iterator.next
    
    if equipment.java_kind_of? DetachedChassis
      if @parent.java_kind_of? DetachedRack
        $facility_api.addChassisToRack equipment, @parent, 0.1
        puts "#{name} - equipment #{equipment.name} entered"
      else
        $facility_api.addItemToPlan equipment, @parent, 100, 100, 0
        puts "#{name} - equipment #{equipment.name} entered"
      end
    else
      #$facility_api.addCardToDevice equipment, @cardbox_chassis, 100, 100, 0
    end
    
  end
  
  def destroy
  	if !@@simulated
      @reader.destroy
  	end
  end
  
  private
  
  def initialize_astra_reader #initialize the astra reader    
    begin
    	if !@@simulated
        @reader = Reader.create(@reader_url);
        @reader.connect();
        @reader.paramSet("/reader/region/id", REGION);  	
    	end
      puts "reader #{name} initialized"
      true
    rescue Exception => e
    	puts "#{name} - #{e.message}"
    	false
    end    
  end
  
  def configure_containers #configure the virtual chassis container
	  #find the parent entity
	  [DetachedPlan.java_class, DetachedRack.java_class].each { |klass| 
	    @parent = find_entity_by_name klass, @parent_entity_name
	    break if !@parent.nil?
	  }
  	raise ApplicationError, "configure_containers - parent entity #{parent_entity_name} not found" if @parent.nil?
  	
    #find the models of the virtual containers
    cardbox_chassis_model = get_model(LibrarySearchFilter.createChassisFilter(CARDBOXCHASSISSPEC))
    raise ApplicationError, "configure_containers - #{CARDBOXCHASSISSPEC} not found in the library" if cardbox_chassis_model.nil?
    
    #search the virtual containers and create if not found
    if @parent.java_kind_of? DetachedRack
      @cardbox_chassis = find_entity_by_name DetachedChassis.java_class, "cardbox chassis-#{@parent.name}" 
      if @cardbox_chassis.nil?
        @cardbox_chassis = $facility_api.createChassis(cardbox_chassis_model,"cardbox chassis-#{@parent.name}")
        $facility_api.addChassisToRack(@cardbox_chassis, @parent, 100);
        raise ApplicationError, "configure_containers - could not add cardbox" if @cardbox_chassis.nil?
      end
    elsif @parent.java_kind_of?(DetachedPlan) 
      @cardbox_chassis = find_entity_by_name DetachedChassis.java_class, "cardbox chassis-#{@parent.name}" 
      if @cardbox_chassis.nil?
        @cardbox_chassis = $facility_api.createChassis(cardbox_chassis_model,"cardbox chassis-#{@parent.name}")
        $facility_api.addItemToPlan(@cardbox_chassis, @parent, 100,100,0);
        raise ApplicationError, "configure_containers - could not add cardbox" if @cardbox_chassis.nil?
      end
    else
      raise ApplicationError, "configure_containers - wrong parent type"
    end
  end
end

