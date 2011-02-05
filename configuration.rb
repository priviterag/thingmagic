require 'java'
java_import com.thingmagic.Reader

VISHOST = 'localhost' # Visionael NRM10 server
VISPORT = 3700 # Visionael NRM10 server port

VCHASSISSPEC = '2201 Rack Assembly' # 13 slot virtual chassis used to place cards
VRACKSPECK = 'Bell Atlantic 5ESS' # virtual rack used to place devices

#readers configuration
DURATION = 500 # the time to spend reading tags, in milliseconds 
REGION = Reader::Region::NA 

READERS = [
  ['FP-bay002-Centigram Cabinet-001', 'tmr://192.168.1.200'],
  ['FP-bay002-System Cabinet-001', 'tmr://192.168.1.201'],
  ['Atlanta Datacenter', 'tmr://192.168.1.202']  
]
