#!/usr/bin/env jruby

require 'visionael'
require 'configuration'

begin
  #initialize module
  visionael_init VISHOST, VISPORT
  
  $facility_api.find(Query.find(DetachedRack.java_class).like('name','cardbox*')).getRootEntities.each { |e| 
    puts "deleting #{e.name}"
    $facility_api.deleteRack e
  }
  
  $facility_api.find(Query.find(DetachedChassis.java_class).like('name','cardbox*')).getRootEntities.each { |e| 
    puts "deleting #{e.name}"
    $facility_api.deleteChassis e
  }
  
rescue ApplicationError => e
  puts e.message
rescue Exception => e
  puts e.message
end


