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
	  
	  #find the parent entity
	  [DetachedPlan.java_class, DetachedBayline.java_class, DetachedRack.java_class].each { |klass| 
	    @parent = find_entity_by_name klass, @parent_entity_name
	    break if !@parent.nil?
	  }
  	raise ApplicationError, "Parent entity #{parent_entity_name} not found" if @parent.nil?
    
    #initialize the astra reader
    begin
    	if !@@simulated
        @reader = Reader.create(@reader_url);
        @reader.connect();
        @reader.paramSet("/reader/region/id", REGION);  	
      else
      	@initialized = true
    	end
      puts "reader #{name} initialized"
    rescue Exception => e
    	@initialized = false
    	puts "#{name} - #{e.message}"
    end    
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
  
  def destroy
  	if !@@simulated
      @reader.destroy
  	end
  end
  
end

