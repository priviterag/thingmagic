require 'visionael'
require 'proxyreader'
require 'configuration'

begin
  #initialize module
  visionael_init VISHOST, VISPORT
  
  #handle <CTRL+C>
  interrupted = false
  trap("INT") { interrupted = true }
  
  puts 'initializing readers...'  
  readers = []
  READERS.each { |reader| 
    begin
      r = ProxyReader.new(reader[0],reader[1])
      readers << r if r.initialized
    rescue Exception => e
      puts e.message      
    end
  }

  threads = []
  puts 'starting readers...' if !readers.empty?
  readers.each { |reader| 
    next if !reader.initialized
    threads << Thread.new(reader) { |r|
      puts "#{r.name} started"
      while !interrupted
        begin
          tags = r.read(DURATION)
          tags.each { |tag| 
            puts "#{r.name} - tag read - #{tag.epcString}" 
            r.process_tag tag.epcString
            sleep(SLEEP_MIN+rand(SLEEP_RANGE)) if r.simulated?
          }
        rescue Exception => e
          puts "#{r.name} error - #{e.message}"
        end
      end
      r.destroy
      puts "#{r.name} stopped"
    }
  }
  threads.each {|thr| thr.join }
rescue ApplicationError => e
  puts e.message
rescue Exception => e
  puts e.message
end


