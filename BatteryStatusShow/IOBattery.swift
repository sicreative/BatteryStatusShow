///
//  IORegistry.swift
//  BatteryStatusShow
//
//  Created by slee on 2017/5/10.
//  Copyright © 2017年 sicreativelee. All rights reserved.
//

import Cocoa
import os.log
import IOKit






class IOBattery{
    
 
    
   public var propertystring: String!
    
   public class IOBatteryRecord{
    var voltage:Float
    var current:Int
    var duration:Int
    var timestamp:Int
    init(_ voltage:Float,_ current: Int,_ timestamp:Int,_ lasttimestamp:Int){
        self.voltage = voltage
        self.current  = current
        self.timestamp = timestamp
        self.duration = timestamp - lasttimestamp
        
    }
    
    
    }
    
    static let updatenotify = AppDelegate.programprefix + ".ionotifyupdate"
    static let lognotify = AppDelegate.programprefix + ".ionotifylog"
        static let userdefaultloggingkey = "default_logging"
    static let userdefaultloggingserialkey = "default_loggingserial"
    
     var timer: DispatchSourceTimer?
    var interval:Int = 20
    
    var  batteryMatchDictionary:NSDictionary!
    var iterator:io_iterator_t = io_iterator_t()
    var iomasterport:mach_port_t = mach_port_t()
    var voltage:Float = 0
    var battery_manufacturer:String = ""
    var battery_serialno:String = ""
    var device_name:String = ""
    var battery_status = ""
  
    var ischarge = false
    var withcharger = false
    var capacity:Int = 0
    var max_capacity:Int = 0
    var design_capacity:Int = 0
    var cycle_count:Int = 0
    var design_cycle:Int = 0
    var temperature:Int = 0
    var amperage:Int = 0
    var avgtimetofull:Int = 0
    var firstrun:Bool = true
    var nobattery:Bool = false
    var lastupdatetime:NSNumber = 0
    var batterymanfdate:String = ""
    var batteryrecord:[Int:IOBatteryRecord]
    
    var powerconsumed:Float = 0
    var avgpower:Float = 0
    var runtime:Int = 0
    var estimatedtime:String = ""
    var chargelevel:String=""
    
 
    var adapterDesc:String=""
    var adapterWatts:String=""
    var adapterManu:String=""
    
    
    var withIOSDevice:Bool = false
    
    var iosBatterySerialNumber:String = ""
    var iosCycle:Int = 0
    var iosDesignCapacity:Int=0
    var iosMaxCapacity:Int=0
    var iosCurrentCapacity:Int=0
    var iosBatteryTemp:Float=0
    var iosUpdateTime:Int=0
    var iosVoltage:Float=0
    var iosModel:String=""
    var iosIsCharging:Bool=false
    var iosFullyCharged:Bool=false
    var iosManufacturer:String=""
    var iosAmperage:Int=0
    var iosTimeRemaining:Int=0
    
    var iosAdapterVoltage:Float=0
    var iosAdapterAmperage:Int=0
    var iosAdapterDesc:String=""
    var iosAdapterWatts:Float=0
    
    var logging:Bool=false
    var loggingSerialNo:String = ""
    
    var macname:String=""
    var macmodel:String=""
    var macdesc:String=""
    var macserialno:String=""
    
    var iosproducttype:String=""
    var ioscomputername:String=""
    var iosdevicecolor:NSColor!
    var iosproductversion:String=""
    var iosserialno:String=""
    var iosproductname:String=""
    var iosmanufdate:String=""
    
    
  

    
    
    var datacontroller:DataController!
    
    
    var save = false
    
  
    
    
   
    

    
    init(){
        
        
      // updatebattery()
      //  commandlineshowinfo()
        batteryrecord = Dictionary()
        
        
        
            datacontroller = (NSApplication.shared.delegate as! AppDelegate).getDataController()
        
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(IOBattery.lognotify), object:nil, queue: nil){notification in
            
            switch (notification.userInfo?["trigger"] as! String){
                case "start":
                    self.logging = true
                    UserDefaults.standard.set(true, forKey: IOBattery.userdefaultloggingkey)
                    self.loggingSerialNo = notification.userInfo?["serialno"] as! String
                    UserDefaults.standard.set(self.loggingSerialNo, forKey: IOBattery.userdefaultloggingserialkey)
                
                     let logFetch :NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Log")
                    logFetch.sortDescriptors = [NSSortDescriptor(key: "time", ascending: true)]
                    
                    logFetch.predicate = NSPredicate(format:"( serialno = %@ )",self.loggingSerialNo)
                    
                    do {
                        let   history = try self.datacontroller.managedObjectContext.fetch(logFetch) as! [LogMO]
                        if (history.count==0 || history[history.count-1].time != Date(timeIntervalSince1970: TimeInterval(truncating: self.lastupdatetime))){
                        
                            self.insertlog("Log", Int32(self.capacity),Int32(self.max_capacity),Int32(self.design_capacity),Date(timeIntervalSince1970:self.lastupdatetime as! TimeInterval) ,Int32(self.cycle_count) , NSNumber(value: self.tempKtoC()), self.loggingSerialNo as NSString, Int32(self.amperage), self.voltage, self.ischarge, !self.withcharger)
                            
                         
                            
                            NotificationCenter.default.post(name:Notification.Name(rawValue:IOBattery.updatenotify),object:nil)
                            
                            
                        }
                    }catch{
                        
                }

                case "stop":
                    self.logging = false
                  UserDefaults.standard.set(false, forKey: IOBattery.userdefaultloggingkey)
                default:
                    break
                
            }
            
                   }
        
              
        update()
        
        logging = UserDefaults.standard.bool(forKey: IOBattery.userdefaultloggingkey)
       if let lserial =   UserDefaults.standard.string(forKey: IOBattery.userdefaultloggingserialkey)  {
            loggingSerialNo = lserial
        }
        
        
        
        if (logging  && loggingSerialNo == battery_serialno){
            NotificationCenter.default.post(name:Notification.Name(IOBattery.lognotify), object: nil, userInfo: ["trigger":"start","serialno":battery_serialno])
        }else{
            NotificationCenter.default.post(name:Notification.Name(IOBattery.lognotify), object: nil, userInfo: ["trigger":"stop"])
        }
        
    }
    
    
    func setChangeLevel(value:Int){
        
        if (value < 40 || value > 100){
            return
        }
        
        let hex = String(format:"%02X", value)
            
        NSAppleScript(source: "do shell script \"sudo \(Bundle.main.bundlePath)/Contents/Resources/smcutil -w BCLM \(hex) \" with administrator " +
               "privileges")!.executeAndReturnError(nil)
        
        
        
     
        
       
        
    }

    func updatebattery(){
        
        
        
        
        
        iosioregclaim()
        
        
        ioregMacDetail()
        

        
        
       batteryMatchDictionary = IOServiceNameMatching("AppleSmartBattery")
      //  batteryMatchDictionary = IOServiceGetMatchingServices("AppleSmartBattery");
        IOMasterPort(mach_port_t(MACH_PORT_NULL), &iomasterport)
       var waittime = mach_timespec_t(tv_sec: 1,tv_nsec: 0);
        
        IOServiceWaitQuiet(iomasterport, &waittime)
        
    
        
        if (IOServiceGetMatchingServices(iomasterport,batteryMatchDictionary,&iterator)==kIOReturnSuccess){
        
        
            
            ioregclaim()
        }
        
       
        let runSMC_BCLM = runCommand(cmd:"\(Bundle.main.bundlePath)/Contents/Resources/smcutil",args:"-r", "BCLM")
                   
                   
        chargelevel = runSMC_BCLM.output[0]
        
        
      
        
        
                
        return ;
    }
    
    
    
    func iosioregclaim(){
        
        var device:idevice_t?
        var lockdown_client:lockdownd_client_t?
        var diagnostics_client:diagnostics_relay_client_t?
        var ret:lockdownd_error_t = LOCKDOWN_E_UNKNOWN_ERROR
        var service:lockdownd_service_descriptor_t?
        
        
     
        
        let udid:UnsafePointer<Int8>! = nil
   

        
        
        
        
        if (IDEVICE_E_SUCCESS != idevice_new(&device, udid)) {
            if ((udid) != nil) {
           //     print(String(format:"No device found with udid %s, is it plugged in?\n", udid));
            } else {
              //  print("No device found, is it plugged in?\n");
            }
            withIOSDevice = false
        }
        
        
        if (LOCKDOWN_E_SUCCESS != lockdownd_client_new_with_handshake(device, &lockdown_client, "idevicediagnostics")) {
            idevice_free(device);
          //  print("ERROR: Could not connect to lockdownd");
            withIOSDevice = false
            
        }
        
        if (lockdown_client==nil){
            return;
        }
        
        ret = lockdownd_start_service(lockdown_client, "com.apple.mobile.diagnostics_relay", &service);
        if (ret != LOCKDOWN_E_SUCCESS) {
            /*  attempt to use older diagnostics service */
            ret = lockdownd_start_service(lockdown_client, "com.apple.iosdiagnostics.relay", &service);
        }
        lockdownd_client_free(lockdown_client);
        
        
   
        if ((ret == LOCKDOWN_E_SUCCESS) && (service != nil) && ((service?.pointee.port)! > 0)) {
            if (diagnostics_relay_client_new(device, service, &diagnostics_client) != DIAGNOSTICS_RELAY_E_SUCCESS) {
                
                
                print("Could not connect to diagnostics_relay!\n");
                withIOSDevice = false
               
            } else {
                
                //First Query the Mobilegestalt for get Devices Information when connect
                
            if (!withIOSDevice){
                
               
               let keys = plist_new_array();
                plist_array_append_item(keys, plist_new_string("ComputerName"));
                plist_array_append_item(keys, plist_new_string("DeviceVariant"));
                plist_array_append_item(keys, plist_new_string("BoardId"));
                plist_array_append_item(keys, plist_new_string("DeviceColor"));
                plist_array_append_item(keys, plist_new_string("ProductVersion"));
                plist_array_append_item(keys, plist_new_string("ProductType"));
                plist_array_append_item(keys, plist_new_string("SerialNumber"));
            
                     var node:plist_t?
             
                
                
                if (diagnostics_relay_query_mobilegestalt(diagnostics_client, keys, &node) == DIAGNOSTICS_RELAY_E_SUCCESS) {
                    if (node != nil) {
                        var show:UnsafeMutablePointer<Int8>?
                        var len:UInt32 = 0
                        
                        plist_to_xml(node, &show, &len)
                        
                        
                        
                        
                        let output =  String(utf8String: UnsafePointer<CChar>(show!)) ?? ""
                        
                        let data = output.data(using: .utf8)
                        
                        do {let property: NSMutableDictionary = try PropertyListSerialization.propertyList(from: data!, options: PropertyListSerialization.MutabilityOptions.mutableContainers, format: nil) as! NSMutableDictionary
                        
                      let mg = property["MobileGestalt"] as! NSDictionary
                        
                       iosproducttype = mg["ProductType"] as? String ?? ""
                            
                       iosproductname = IOSModelDict.ProductTypeToName(producttype: iosproducttype)
                        
                       ioscomputername = mg["ComputerName"] as? String ?? ""
                        
                        
                        
                        iosdevicecolor = NSColor(hex: mg["DeviceColor"] as? String ?? "000000")
                        
                        iosproductversion = mg["ProductVersion"] as? String ?? ""

                            #if DEBUG
                                iosserialno = "D123456789ABCDE"
                            #else
                                iosserialno = mg["SerialNumber"]  as? String ?? ""
                            #endif
                            
                        }catch{
                            
                        }
                        
                        show?.deinitialize(count: 0)
                        
                        
                  
                        
                       
                        

                    }
                }else{
                    
                    
                    
                    
                }
            }
            
            

            // Query AppleARMPMUCharger 
                
                var node:plist_t?
                
                if (diagnostics_relay_query_ioregistry_entry(diagnostics_client, "AppleARMPMUCharger",nil, &node) == DIAGNOSTICS_RELAY_E_SUCCESS) {
                    if (node != nil) {
                        var show:UnsafeMutablePointer<Int8>?
                        var len:UInt32 = 0
                        
                        plist_to_xml(node, &show, &len)
                        
                        
                        
                      
                     let output =  String(utf8String: UnsafePointer<CChar>(show!)) ?? ""
                        
                        let data = output.data(using: .utf8)
                        
                      
                        
                        do {  let property: NSMutableDictionary = try PropertyListSerialization.propertyList(from: data!, options: PropertyListSerialization.MutabilityOptions.mutableContainers, format: nil) as! NSMutableDictionary
                          propertystring = property.description
                            #if DEBUG
                            print( property.description)
                        
                                
                            #endif
                                
                            let powerdict = property["IORegistry"] as! NSDictionary
                           // let batterydict = powerdict["BatteryData"] as! NSDictionary
                           
                            if (!withIOSDevice){
                                #if DEBUG
                                    iosBatterySerialNumber = "DABCDE1235678"
                                #else
                                    iosBatterySerialNumber = powerdict["Serial"]  as? String ?? ""
                                    if (!withIOSDevice){
                                        os_log("iOS Devices Connected: %{public}@",
                                               iosBatterySerialNumber)
                                    }
                                
                                #endif
                                
                                // Some Battery may no Manufacturer and Model Information 
                                
                                iosManufacturer = powerdict["Manufacturer"]  as? String ?? ""
                            
                              
                                iosModel = powerdict["Model"]  as? String ?? ""
                                
                                if (powerdict["AdapterDetails"] as! NSDictionary! != nil){
                                    if let adapter = powerdict["AdapterDetails"] as! NSDictionary!{
                                        iosAdapterVoltage = Float(truncating: adapter["AdapterVoltage"] as! NSNumber)/1000
                                    
                                        iosAdapterAmperage = Int(truncating: adapter["Amperage"] as! NSNumber)
                                        iosAdapterDesc = adapter["Description"]  as? String ?? ""
                                        iosAdapterWatts = Float(truncating: adapter["Watts"] as! NSNumber)
                                    }
                                }
                                
                                if (powerdict["BatteryData"] as! NSDictionary! != nil){
                                    if let batterydata = powerdict["BatteryData"] as! NSDictionary!
                                    {
                                        let manufactureDate = Int( (batterydata["ManufactureDate"] as! NSString) as String)
                                    
                                        let dateformatter = DateFormatter()
                                        dateformatter.dateStyle = .medium
                                        dateformatter.timeStyle = .none
                                    
                                        var components = DateComponents()
                                    
                                    
                                        components.yearForWeekOfYear = manufactureDate! / 100
                                        components.weekOfYear = manufactureDate! % 100
                                
                                        let calendardate = Calendar.current.date(from: components)
                                        iosmanufdate = dateformatter.string(from: calendardate!)
                                    }
                                }
                                
                              
                                
                                
                              
                                withIOSDevice = true
                                iosUpdateTime = 0
                            }
                            
                            
                            var updateTime:Int!
                            
                            if (powerdict["UpdateTime"]==nil){
                                updateTime = Int(Date().timeIntervalSince1970)
                            }else{
                                updateTime = Int( truncating: powerdict["UpdateTime"] as? NSNumber ?? 0)
                            }
                            
                            
                            if ( iosUpdateTime == updateTime){
                                return
                            }
                            
                           
                            
                            iosUpdateTime = updateTime

                            
                            iosCycle = Int( truncating: powerdict["CycleCount"] as? NSNumber ?? 0)
                            iosDesignCapacity = Int(truncating: powerdict["DesignCapacity"] as? NSNumber ?? 0)
                            iosMaxCapacity = Int(truncating: powerdict["AppleRawMaxCapacity"] as? NSNumber ?? 0)
                            iosCurrentCapacity = Int(truncating: powerdict["AppleRawCurrentCapacity"] as? NSNumber ?? 0)
                            iosBatteryTemp = Float(truncating: powerdict["Temperature"] as? NSNumber ?? 0) / 100
                         
                            iosVoltage = Float(truncating: powerdict["Voltage"] as? NSNumber ?? 0) / 1000
                            
                     
                            iosAmperage = Int(truncating: powerdict["InstantAmperage"] as? NSNumber ?? 0)
                            iosTimeRemaining = Int(truncating: powerdict["TimeRemaining"] as? NSNumber ?? 0)
                           
                            iosIsCharging = powerdict["IsCharging"] as! Bool
                            iosFullyCharged = powerdict["FullyCharged"] as! Bool
                          
                            
                              show?.deinitialize(count: 0)
                            
                            diagnostics_relay_goodbye(diagnostics_client);
                    
                            
                       diagnostics_relay_client_free(diagnostics_client)
                            
                            
                
                            rundatabase("IOSHistory",iosMaxCapacity as NSNumber,
                                        Date(),iosCycle as NSNumber,iosBatteryTemp as NSNumber,iosBatterySerialNumber as NSString)
                            
                            
                          
                            
                        }catch{
                            
                        }
                        
                        
                    
                    }else{
                        // Latest ios device  use AppleSmartBattery for battery information
                        if (diagnostics_relay_query_ioregistry_entry(diagnostics_client, "AppleSmartBattery",nil, &node) == DIAGNOSTICS_RELAY_E_SUCCESS) {
                            if (node != nil){
                                
                                     var show:UnsafeMutablePointer<Int8>?
                                        var len:UInt32 = 0
                                        
                                        plist_to_xml(node, &show, &len)
                                        
                                        
                                        
                                      
                                     let output =  String(utf8String: UnsafePointer<CChar>(show!)) ?? ""
                                        
                                        let data = output.data(using: .utf8)
                                        
                                      
                                        
                                        do {  let property: NSMutableDictionary = try PropertyListSerialization.propertyList(from: data!, options: PropertyListSerialization.MutabilityOptions.mutableContainers, format: nil) as! NSMutableDictionary
                                          propertystring = property.description
                                            #if DEBUG
                                            print( property.description)
                                        
                                                
                                            #endif
                                                
                                            let powerdict = property["IORegistry"] as! NSDictionary
                                           // let batterydict = powerdict["BatteryData"] as! NSDictionary
                                           
                                            if (!withIOSDevice){
                                                #if DEBUG
                                                    iosBatterySerialNumber = "DABCDE1235678"
                                                #else
                                                    iosBatterySerialNumber = powerdict["Serial"]  as? String ?? ""
                                                    if (!withIOSDevice){
                                                        os_log("iOS Devices Connected: %{public}@",
                                                               iosBatterySerialNumber)
                                                    }
                                                
                                                #endif
                                                
                                            // Not all battery provide 
                                            iosManufacturer = powerdict["Manufacturer"]  as? String ?? ""
                                            iosModel = powerdict["Model"]  as? String ?? ""
                                                
                                                if ((powerdict["AdapterDetails"] as! NSDictionary!) != nil){
                                                    if let adapter = powerdict["AdapterDetails"] as! NSDictionary!{
                                                        iosAdapterVoltage = Float(truncating: adapter["Voltage"] as! NSNumber)/1000
                                                    
                                                        iosAdapterAmperage = Int(truncating: adapter["Current"] as! NSNumber)
                                                        iosAdapterDesc = adapter["Description"]  as? String ?? ""
                                                        iosAdapterWatts = Float(truncating: adapter["Watts"] as! NSNumber)
                                                    }
                                                }
                                                
                                                
                                        
                                                
                                              
                                                //  iosmanufdate = powerdict[""] as!
                                                
                                              
                                                withIOSDevice = true
                                                iosUpdateTime = 0
                                            }
                                            
                                            
                                            var updateTime:Int!
                                            
                                            if (powerdict["UpdateTime"]==nil){
                                                updateTime = Int(Date().timeIntervalSince1970)
                                            }else{
                                                updateTime = Int( truncating: powerdict["UpdateTime"] as? NSNumber ?? 0)
                                            }
                                            
                                            
                                            if ( iosUpdateTime == updateTime){
                                                return
                                            }
                                            
                                           
                                            
                                            iosUpdateTime = updateTime

                                            
                                            iosCycle = Int( truncating: powerdict["CycleCount"] as? NSNumber ?? 0)
                                            iosDesignCapacity = Int(truncating: powerdict["DesignCapacity"] as? NSNumber ?? 0)
                                            iosMaxCapacity = Int(truncating: powerdict["AppleRawMaxCapacity"] as? NSNumber ?? 0)
                                            iosCurrentCapacity = Int(truncating: powerdict["AppleRawCurrentCapacity"] as? NSNumber ?? 0)
                                            iosBatteryTemp = Float(truncating: powerdict["Temperature"] as? NSNumber ?? 0) / 100
                                         
                                            iosVoltage = Float(truncating: powerdict["Voltage"] as? NSNumber ?? 0) / 1000
                                            
                                     
                                            iosAmperage = Int(truncating: powerdict["InstantAmperage"] as? NSNumber ?? 0)
                                            iosTimeRemaining = Int(truncating: powerdict["TimeRemaining"] as? NSNumber ?? 0)
                                           
                                            iosIsCharging = powerdict["IsCharging"] as! Bool
                                            iosFullyCharged = powerdict["FullyCharged"] as! Bool
                                          
                                            
                                              show?.deinitialize(count: 0)
                                            
                                            diagnostics_relay_goodbye(diagnostics_client);
                                    
                                            
                                       diagnostics_relay_client_free(diagnostics_client)
                                            
                                            
                                
                                            rundatabase("IOSHistory",iosMaxCapacity as NSNumber,
                                                        Date(),iosCycle as NSNumber,iosBatteryTemp as NSNumber,iosBatterySerialNumber as NSString)
                                            
                                            
                                          
                                            
                                        }catch{
                                            
                                        }
                                
                                
                                
                                
                            }
                            
                            
                        }
                        
                        
                        
                        
                    }
                } else {
                   // print("Unable to retrieve IORegistry from device.\n");
                }
                
                
            }
            
            if (service != nil) {
                lockdownd_service_descriptor_free(service);
                service = nil;
            }

        }
        
        
        idevice_free(device)
        
        
      
        
     
        
        
        
    }
    
    
    func ioregMacDetail(){
        
        
        if (firstrun){
            
            batteryMatchDictionary = IOServiceMatching("IOPlatformExpertDevice")
            IOMasterPort(mach_port_t(MACH_PORT_NULL), &iomasterport)
            var waittime = mach_timespec_t(tv_sec: 1,tv_nsec: 0);
            
            IOServiceWaitQuiet(iomasterport, &waittime)
            
            
            
            if (IOServiceGetMatchingServices(iomasterport,batteryMatchDictionary,&iterator)==kIOReturnSuccess){
                
                IOIteratorReset(iterator);
                
                
                repeat{
                    
                    let io :io_service_t = IOIteratorNext(iterator);
                    
                    
                    
                    
                    
                    
                    if (io==0){
                        break;
                    }
                    
                    
                    
                    
                    let devName = UnsafeMutablePointer<io_name_t>.allocate(capacity: 1);
                    
                    
                    // let devrawName = UnsafeMutableRawPointer(devName).bindMemory(to: io_name_t.self, capacity: 1)
                    
                    let int8Pointer = UnsafeMutableRawPointer(devName).bindMemory(to: Int8.self,capacity: 1)
                    
                    
                    let pathName = UnsafeMutablePointer<io_string_t>.allocate(capacity: 1);
                    
                    let int8NamePointer = UnsafeMutableRawPointer(pathName).bindMemory(to: Int8.self,capacity: 1)
                    
                    
                    IORegistryEntryGetName(io, int8Pointer);
                    
                    IORegistryEntryGetPath(io, kIOServicePlane, int8NamePointer);
                    print(String(format:"Root Devices: %s found. path in IOService plane = %s\n",devName, pathName));
                    
                    int8Pointer.deinitialize(count: 0)
                    int8NamePointer.deinitialize(count: 0)
                    devName.deinitialize(count: 0)
                    pathName.deinitialize(count: 0)
                    
                    
                    var child:Unmanaged<CFMutableDictionary>?
                    
                    IORegistryEntryCreateCFProperties(io, &child, kCFAllocatorDefault, 0)
                    //   IORegistryEntryGetChildIterator(io,kIOServicePlane,&child)
                    
                    let childdict = NSDictionary(dictionary:(child?.takeUnretainedValue())!)
                    
                    //    let model = NSString(data:childdict["model"] as! Data,encoding: String.Encoding.macOSRoman.rawValue )! as String
                    
                    if let model = NSString(cString: (childdict["model"] as! NSData).bytes.assumingMemoryBound(to: Int8.self), encoding: String.Encoding.macOSRoman.rawValue) {
                        macmodel = model as String
                    }
                    
                    #if DEBUG
                        macserialno = "DB12345678901234"
                    #else
                         macserialno = (childdict["IOPlatformSerialNumber"]) as! String
                   #endif
                    
                    let langCode = Locale.current.languageCode
                    var regionCode = Locale.current.regionCode
                    if (regionCode!.count > 0){
                        regionCode!.insert("_", at: .init(encodedOffset: 0))
                    }
                    
                  
                    
                    if let dict = NSDictionary(contentsOfFile: "/System/Library/PrivateFrameworks/ServerInformation.framework/Resources/\(langCode!)\(regionCode!).lproj/SIMachineAttributes.plist") as? [String:AnyObject] {
                        
                        if (dict[macmodel] as? NSDictionary) == nil {
                                                       return
                                                   }
                        
                        macname = ((dict[macmodel] as! NSDictionary)["_LOCALIZABLE_"] as! NSDictionary)["marketingModel"] as! String
                        
                        macdesc = ((dict[macmodel] as! NSDictionary)["_LOCALIZABLE_"] as! NSDictionary)["description"] as! String
                        
                        
                        
                        
                        
                    }else{
                        if let dict = NSDictionary(contentsOfFile: "/System/Library/PrivateFrameworks/ServerInformation.framework/Resources/\(langCode!).lproj/SIMachineAttributes.plist") as? [String:AnyObject] {
                            
                            if (dict[macmodel] as? NSDictionary) == nil {
                                return
                            }
                        
                            macname = ((dict[macmodel] as! NSDictionary)["_LOCALIZABLE_"] as! NSDictionary)["marketingModel"] as! String
                        
                            macdesc = ((dict[macmodel] as! NSDictionary)["_LOCALIZABLE_"] as! NSDictionary)["description"] as! String
                            
                        }else{
                            
                            
                            
                            if let dict = NSDictionary(contentsOfFile: "/System/Library/PrivateFrameworks/ServerInformation.framework/Resources/en.lproj/SIMachineAttributes.plist") as? [String:AnyObject] {
                                
                                if (dict[macmodel] as? NSDictionary) == nil {
                                                               return
                                                           }
                            
                                macname = ((dict[macmodel] as! NSDictionary)["_LOCALIZABLE_"] as! NSDictionary)["marketingModel"] as! String
                            
                                macdesc = ((dict[macmodel] as! NSDictionary)["_LOCALIZABLE_"] as! NSDictionary)["description"] as! String
                            }
                            
                            
                            
                        }
                        
                    }
                    
                   
                    
                    
                    // ioregclaim()
                }while(IOIteratorIsValid(iterator)==boolean_t(truncating: true))
            }
        }
        
        
    }
    
    
    func ioregclaim(){
        
      // CFDictionaryGetValue
        
        IOIteratorReset(iterator);
        
        nobattery = true;
        
        
        repeat{
        
            let io :io_service_t = IOIteratorNext(iterator);
            
            
            
        
         
            
            if (io==0){
                break;
            }
            
            nobattery = false;
          
            
            if (firstrun){
            
            
           let devName = UnsafeMutablePointer<io_name_t>.allocate(capacity: 1);
       
            
          
            
            let int8Pointer = UnsafeMutableRawPointer(devName).bindMemory(to: Int8.self,capacity: 1)
            
            
            let pathName = UnsafeMutablePointer<io_string_t>.allocate(capacity: 1);
            
            let int8NamePointer = UnsafeMutableRawPointer(pathName).bindMemory(to: Int8.self,capacity: 1)

            
            IORegistryEntryGetName(io, int8Pointer);
           
            IORegistryEntryGetPath(io, kIOServicePlane, int8NamePointer);
                
         
                
            
            int8Pointer.deinitialize(count: 0)
            int8NamePointer.deinitialize(count: 0)
            devName.deinitialize(count: 0)
            pathName.deinitialize(count: 0)
                
                
                firstrun = false
                
            }
            
            

         //   IORegistryEntryGetPath(io, kIOUSBPlane, pathName);
         //   printf("Device's path in IOUSB plane = %s\n", pathName);
            
            var child:Unmanaged<CFMutableDictionary>?
        
           IORegistryEntryCreateCFProperties(io, &child, kCFAllocatorDefault, 0)
         //   IORegistryEntryGetChildIterator(io,kIOServicePlane,&child)
            
            let childdict = NSDictionary(dictionary:(child?.takeUnretainedValue())!)
            
            
            let updatetime : NSNumber
            
            if (childdict["UserVisiblePathUpdated"] == nil){
                updatetime = NSNumber(value : Double(Date().timeIntervalSince1970))
                firstrun = true
             
                
            }else{
                updatetime =  childdict["UserVisiblePathUpdated"] as? NSNumber ?? 0
            }
            
           
            
        
            
            if ( updatetime==lastupdatetime){
                child?.release()
                IOObjectRelease(io)
                return
            }
            
            
            
    
            
            
            
            
            
            
            
            for (key, value) in childdict{
               let keystring:String = key as! String
               // print(keystring);
               // print(String(format:"key: %@ found\n",keystring));
                
                switch keystring {
                    case "Voltage":
                        voltage = Float(truncating: value as? NSNumber ?? 0)
                        voltage /= 1000
                    case "CurrentCapacity":
                        capacity = Int(truncating: value as? NSNumber ?? 0)
                    case "DesignCapacity":
                        design_capacity = Int (truncating: value as? NSNumber ?? 0)
                    case "MaxCapacity":
                        max_capacity = Int (truncating: value as? NSNumber ?? 0)
                    case "CycleCount":
                        cycle_count = Int (truncating: value as? NSNumber ?? 0)
                    case "BatterySerialNumber","Serial":
                        if (battery_serialno.isEmpty){
                            #if DEBUG
                                battery_serialno = "C412345678901"
                            #else
                               // Display Debug information for first connected
                              //  os_log("Battery information:\n %{public}@",childdict.description)
                                  battery_serialno = value as! String
                                   os_log("Battery Devices: %{public}@ found.",battery_serialno);
                              
                            #endif
                            
                    }
                    case "Manufacturer":
                        if (battery_manufacturer.isEmpty){
                            battery_manufacturer = value as! String
                    }
                    case "DeviceName":
                        if (device_name.isEmpty){
                            device_name = value as! String
                    }
                    case "DesignCycleCount9C":
                        design_cycle = Int (truncating: value as? NSNumber ?? 0)
                    case "Temperature":
                        temperature = Int (truncating: value as? NSNumber ?? 0)
                    
                    case "Amperage":
                        amperage = Int (truncating: value as? NSNumber ?? 0)
                    
                 
                    
                   case "ExternalConnected":
                        withcharger = value as! Bool
                    
                    case "IsCharging":
                        ischarge = value as! Bool
                    
                    case "AvgTimeToFull":
                        avgtimetofull = value  as! Int
                    
                    case "PermanentFailureStatus":
                        if (value as? NSNumber ?? 0 == 0){
                        battery_status = "Normal"
                        }else{
                        battery_status = "Failure"}
                    
                    case "ManufactureDate":
                        if (batterymanfdate.isEmpty){
                            let rawnum = Int(truncating: value as? NSNumber ?? 0)
                        let date = rawnum & 0x1F
                        let month = (rawnum & 0x1E0) >> 5
                        let year = (rawnum >> 9 ) + 1980
                        
                        
                    
                        let dateformatter = DateFormatter()
                        dateformatter.dateStyle = .medium
                        dateformatter.timeStyle = .none
                        
                        var components = DateComponents()
                        components.day = date
                        components.month = month
                        components.year = year
                        let calendardate = Calendar.current.date(from: components)
                        batterymanfdate = dateformatter.string(from: calendardate!)
                    }

                    default:
                        
                        break
                    
                }

            }
            
            if (withcharger){
                
                
                
                
                let runfinished = runCommand(cmd:"/usr/sbin/system_profiler",args:"-xml", "SPPowerDataType")
                
                
                let data = runfinished.output[0].data(using: .utf8)
                
                
                
                do {  let property: NSArray = try PropertyListSerialization.propertyList(from: data!, options: PropertyListSerialization.MutabilityOptions.mutableContainers, format: nil) as! NSArray
                    
                    let ac =  ((property[0] as! NSDictionary)["_items"] as! NSArray)[3] as! NSDictionary
                    if (ac["_name"] as! String == "sppower_ac_charger_information"){
                        
                        if let value = ac["sppower_ac_charger_manufacturer"]{
                             adapterManu = value as! String
                        }
                        
                        if let value = ac["sppower_ac_charger_name"] {
                            adapterDesc = value as! String
                        }
                        
                        if let value = ac["sppower_ac_charger_watts"] {
                            adapterWatts = value as! String
                        }
                  
                      
                    }
                    
                }catch{
                    
                }

                
                
            }
            
            
           
                
           
           
            /*
                 let childio :io_object_t = IOIteratorNext(child);
                if (childio==0){
                        break;
                }
                
                let childName = UnsafeMutablePointer<io_name_t>.allocate(capacity: 1);
                let childint8Pointer = UnsafeMutableRawPointer(childName).bindMemory(to: Int8.self,capacity: 1)
                  IORegistryEntryGetName(child, childint8Pointer);
                print(String(format:"Child: %s found\n",childName));
                childint8Pointer.deinitialize()
                childName.deinitialize()
                
                
                
                

                
                
                
            }while(IOIteratorIsValid(child)==boolean_t(true))
 */
        
      
            
            processrecord(Int(truncating: updatetime))
            
            lastupdatetime = updatetime
            
            
            child?.release()
                  
            IOObjectRelease(io)
            

            updatestatusitem()
            
            
            

            
            rundatabase ("History", self.max_capacity as NSNumber, Date(timeIntervalSince1970: updatetime as! TimeInterval), self.cycle_count as NSNumber, self.tempKtoC() as NSNumber, self.battery_serialno as NSString)
            
            
        }while(IOIteratorIsValid(iterator)==boolean_t(truncating: true))
        
        
      
        
        
        return;
        
        
      // for (key, value) in batteryMatchDictionary as! NSDictionary {
      //     print("Value: \(value) for key: \(key)")
      //  }
     //  print("batteryMatchDictionary count:\((batteryMatchDictionary[0] as! NSDictionary).count) items")
    }
    
    func processrecord(_ updatetime:Int){
        
        batteryrecord[updatetime] = IOBatteryRecord(voltage,amperage,updatetime,Int(truncating: lastupdatetime))
        
        
        if (withcharger && !ischarge){
            avgpower = 0
            estimatedtime = ""
            return;
        }
        
        if (lastupdatetime == 0){
            lastupdatetime = NSNumber(value: updatetime)
        }
        
        if ((avgpower <= 0 && amperage > 0)||(avgpower >= 0 && amperage < 0)){
            runtime = 0
            avgpower = voltage * Float(amperage) / 1000
            powerconsumed = 0
        
        }else{
            runtime += batteryrecord[updatetime]!.duration
            
            if (runtime==0){
                avgpower  = voltage * Float(amperage) / 1000
            } else {
            
            powerconsumed += voltage * (Float(amperage) / 1000) * ( Float (batteryrecord[updatetime]!.duration) / 3600 )
            avgpower = powerconsumed * 3600 / Float(runtime)
            }
            
            
            

        }
        
        
        
        var runninghour:Float
        
        if (ischarge){
            runninghour = Float(avgtimetofull) / 60
        }else{
            
            if (avgpower == 0){
                runninghour = 0
            }else{
            
            
            runninghour =  ( Float( capacity) * voltage / 1000 ) / abs(avgpower)
            }
        }
        
        if (runninghour != 0 ){
        
        let hour = Int(runninghour.rounded(.towardZero))
        
        let min = Int(runninghour.truncatingRemainder(dividingBy: 1)  * 60)
        
        
        
        estimatedtime = String(format:"%d:%02d",hour,min)
        }else{
          estimatedtime = String(format:"%d:%02d",0,0)
        }
        
     
        

        
    }
    
    func batteryhealthpercent()->Float{

    
       return ((Float(max_capacity) / Float(design_capacity)) * 100.0)
    }
    
    func batterypercentage()->Float{
        return ((Float(capacity) / Float(max_capacity)) * 100.0)
    }
    
    func iosbatteryhealthpercent()->Float{
        
        
        return ((Float(iosMaxCapacity) / Float(iosDesignCapacity)) * 100.0)
    }
    
    func iosbatterypercentage()->Float{
        return ((Float(iosCurrentCapacity) / Float(iosMaxCapacity)) * 100.0)
    }
    
    
    
    func tempKtoC()->Float{
           return Float(temperature-2732) / 10
    }
    
    func tempKtoF()->Float{
        return Float(temperature) * 0.18 - 459.67
    }
    
    func power()->Float{
        return Float(amperage) / 1000 * voltage
    }
    
    func iospower()->Float{
        return Float(iosAmperage) / 1000 * iosVoltage
    }
    
    
    
    
    func startTimer() {
     
        let queue = DispatchQueue(label: ( AppDelegate.programprefix + "." + String(describing: type(of: self))), attributes: .concurrent)
        
        timer?.cancel()        // cancel previous timer if any
        
        timer = DispatchSource.makeTimerSource(queue: queue)
        
        timer?.schedule(deadline: .now(), repeating: .seconds(interval), leeway: .seconds(1))
        
        timer?.setEventHandler { // `[weak self]` only needed if you reference `self` in this closure and you want to prevent strong reference cycle
            
            
            self.update()
            
            
        }
        
        timer?.resume()
    }
    
    func stopTimer() {
         databasesave()
        timer?.cancel()
        timer = nil
    }
    
    private func update(){
       
        updatebattery()
        
       // DispatchQueue.main.async {
             self.databasesave()
      //  }
       
        

            NotificationCenter.default.post(name:Notification.Name(rawValue:IOBattery.updatenotify),object:nil)
       
        
        
     
   
            
        
        
        
       
        
   

        
       
        
        
    }
    
    
    func updatestatusitem(){
        
        
        
        let changestatus: BatteryStatusItem.ChangeStatus
        
        if (self.nobattery){
            changestatus = .nobattery
            
        }
        else  if (self.ischarge){
            if (self.power()>10.0){
                changestatus = .change_fast
            }else{
                changestatus = .change_slow
            }
        }else if (!self.withcharger){
            
            // For Macbook Pro
            if (self.voltage>10){
                if (self.power()>12.0){
                    changestatus = .dischange_fast
                }else if (self.power()>6.0){
                    changestatus = .dischange_slow
                }else{
                    changestatus = .dischange_verylight
                }
            }else{
                // For Macbook Air / Macbook
                if (self.power() < -8.0){
                    changestatus = .dischange_fast
                }else if (self.power() < -4.5){
                    changestatus = .dischange_slow
                }else {
                    changestatus = .dischange_verylight
                }
            }
            
        }else{
            changestatus = .nochange
            
        }
        
        DispatchQueue.main.async{
            (NSApplication.shared.delegate as! AppDelegate).updatestatusbutton(chargestatus:changestatus,batterylevel: self.nobattery ? 3 : Int(Double(self.capacity)/Double(self.max_capacity)*5))
        }
         //   (NSApplication.shared().delegate as! AppDelegate).updatestatusbutton(chargestatus:changestatus,batterylevel: nobattery ? 3 : 5)
        
        

        
    }
    
    
    func rundatabase(_ entityname:String,_ capacity:NSNumber,_ time:Date,_ cycle:NSNumber,_ temp:NSNumber,_ serialno:NSString ){
        
        if (datacontroller==nil){
         datacontroller = (NSApplication.shared.delegate as! AppDelegate).getDataController()
        }
        
        do {
            
            
            let historyFetch :NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityname)
            
            
            let calendar = Calendar.current
            // print(calendar.timeZone.description)
            // calendar.timeZone = NSTimeZone.local
            let yesterday:NSDate = calendar.startOfDay(for: Date()) as NSDate
            let tomorrow:NSDate = calendar.startOfDay(for: Calendar.current.date(byAdding: .day, value:1, to: Date())!) as NSDate
            
            
            
            
            
            historyFetch.predicate = NSPredicate(format:"(time between {%@,%@} AND serialno = %@ )",yesterday, tomorrow,serialno)
            
            
            let historycontent = try datacontroller.managedObjectContext.fetch(historyFetch) as! [HistoryMO]
            
            
            if (historycontent.count == 0 ){
                
                
                
                DispatchQueue.main.async {
                    self.insertdatabase(entityname, capacity, time, cycle , temp, serialno)
                }
              
                
                
                
                #if DEBUG
                              self.addtest(entityname)
                #endif 
                
            }
            
                
                
                
           
                
        }catch{
            fatalError("Failure to get context: \(error)")

        }
            
            
            if (logging){
                
                if (loggingSerialNo == ""){
                    logging = false 
                     return
                }
                
                
                if (serialno as String == loggingSerialNo){
                    insertlog("Log", Int32(self.capacity),  Int32(max_capacity) , Int32(design_capacity),time,Int32(truncating: cycle),temp, serialno,Int32(amperage),voltage,ischarge,!withcharger)
                    
                }
                
             
                
                
                
            }
        
        

        
        
            
            
            
            
            
            
      
        
        
        
    }
    
    func databasesave(){
        
   
        
        if (!save){
            return;
        }
        
        datacontroller.managedObjectContext.performAndWait(){
    
            if ( self.datacontroller.managedObjectContext.hasChanges){
                do { try self.datacontroller.managedObjectContext.save()
                }catch{
                
                         fatalError("Failure to save context: \(error)")
                        }
                }
            self.save = false;
        }
   
    }
    
    func insertdatabase(_ entityname:String,_ capacity:NSNumber,_ time:Date,_ cycle:NSNumber,_ temp:NSNumber,_ serialno:NSString ){
        
        
        let history = NSEntityDescription.insertNewObject(forEntityName: entityname, into: datacontroller.managedObjectContext) as! HistoryMO
        
        history.capacity = capacity
        history.time = time
        history.cycle = cycle
        history.temperature = temp
        history.serialno = serialno
        
        save = true
        
    }
    
    func insertlog(_ entityname:String,_ capacity:Int32,_ maxcapcity:Int32,_ designcapcity:Int32,_ time:Date ,_ cycle:Int32,_ temp:NSNumber,_ serialno:NSString,_ current:Int32,_ voltage:Float,_ ischange:Bool,_ usebattery:Bool ){
        
        let history = NSEntityDescription.insertNewObject(forEntityName: entityname, into: datacontroller.managedObjectContext) as! LogMO
        
        history.capacity = capacity
        history.designcapacity = designcapcity
        history.maxcapacity = maxcapcity
        history.time = time
        history.cycle = cycle
        history.temperature = Float(truncating: temp)
        history.serialno = serialno as String
        history.current = current
        history.voltage = voltage
        history.charging = ischange
        history.usebattery = usebattery
        
        save = true
    }
    
    
    func runCommand(cmd : String, args : String...) -> (output: [String], error: [String], exitCode: Int32) {
        
        var output : [String] = []
        var error : [String] = []
        
        let task = Process()
        task.launchPath = cmd
        task.arguments = args
        
        let outpipe = Pipe()
        task.standardOutput = outpipe
        let errpipe = Pipe()
        task.standardError = errpipe
        
        task.launch()
        
 
        
        
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data:outdata,encoding: .utf8) {
            string = string.trimmingCharacters(in: (NSCharacterSet.newlines))
           output = [string]
            // output = string.components(separatedBy:"\n")
        }
        
        let errdata = errpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data:errdata,encoding: .utf8) {
           string = string.trimmingCharacters(in: (NSCharacterSet.newlines))
            error = string.components(separatedBy:"\n")
        }
        
        task.waitUntilExit()
        let status = task.terminationStatus
        
        return (output, error, status)
    }
    
    
    
    
    func addtest(_ entityname:String){
        
        let csv = readDataFromFile(file: (entityname=="History") ? "battery" : "iosbattery")
        
        let lines = csv?.components(separatedBy: "\n")
        
        let dateformatter = DateFormatter()
        dateformatter.locale = Locale(identifier: "en_US_POSIX")
        
        dateformatter.timeStyle = .none
        
        dateformatter.dateFormat = "yyyy-MM-dd"
        
        dateformatter.timeZone = Calendar.current.timeZone
       // print (dateformatter.string(from: Date()))
        
        for line in lines!{
            
            if (line == ""){
                continue;
            }
            
            let commas = line.components(separatedBy: ",")
            let history = NSEntityDescription.insertNewObject(forEntityName: entityname, into: datacontroller.managedObjectContext) as! HistoryMO
            
            if (commas.count<4){
                continue
            }
            
            
            
            
            history.time = dateformatter.date(from: commas[0])
            
            history.capacity = Int(commas[1])! as NSNumber
            
            history.cycle = Int(commas[2])! as NSNumber
            
            history.temperature = Float(commas[3])! as NSNumber
            
            history.serialno = ((entityname=="History") ? battery_serialno : iosBatterySerialNumber )as NSString
            
            
            
        }
    }
    
    
    func readDataFromFile(file:String)-> String!{
        
        guard let filepath = Bundle.main.path(forResource: file, ofType: "csv")
            else {
                return nil
        }
        do {
            let contents = try String(contentsOfFile: filepath)
            return contents
        } catch {
            print("File Read Error for file \(filepath)")
            return nil
        }
    }


    
    
}


extension NSColor {
    convenience init(r: Int, g: Int, b: Int, a: Int = 255) {
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a) / 255.0)
    }
    
    convenience init(hex:String) {
        
          var hexstring = "000000";
        
        if (!hex.isEmpty && hex[hex.startIndex]=="#"){
            hexstring =  String(hex[hex.index(hex.startIndex, offsetBy: 1)..<hex.endIndex])
        }
        
            
       // hexstring.insert("x", at: hexstring.startIndex)
       // hexstring.insert("0", at: hexstring.startIndex)
        
        let intvalue =   Int(hexstring,radix:16)
        
      
        
    //   = (hexstring as NSString).integerValue
       
        
        
        self.init(r:(intvalue! >> 16) & 0xff, g:(intvalue! >> 8) & 0xff, b:intvalue! & 0xff)
    }
}



