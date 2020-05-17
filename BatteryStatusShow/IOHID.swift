//
//  IOHID.swift
//  BatteryStatusShow
//
//  Created by slee on 2017/5/23.
//  Copyright © 2017年 sicreativelee. All rights reserved.
//

import Cocoa

class IOHID{
    
    static let updatenotify = AppDelegate.programprefix + ".iohidnotifyupdate"
    
    

    
    var timer: DispatchSourceTimer?
    var interval:Int = 20
    
    var  batteryMatchDictionary:NSDictionary!
    var iterator:io_iterator_t = io_iterator_t()
    var iomasterport:mach_port_t = mach_port_t()

    var devices_name:[String] = [String]()
    var batterylevel:[Int] = [Int]()
    var devices_serialno:[String] = [String]()
    var status_flag:[Int]=[Int]()
    var updating:Bool = false

  
    

  
    var nodevices:Bool = false
   
 
    
    
    
    
    init(){
        // updatebattery()
        //  commandlineshowinfo()
        
        update()
        
    }
    
    func updateHID(){
        
        
        
        batteryMatchDictionary = IOServiceNameMatching("AppleDeviceManagementHIDEventService")
        //  batteryMatchDictionary = IOServiceGetMatchingServices("AppleSmartBattery");
        IOMasterPort(mach_port_t(MACH_PORT_NULL), &iomasterport)
        var waittime = mach_timespec_t(tv_sec: 1,tv_nsec: 0);
        
        IOServiceWaitQuiet(iomasterport, &waittime)
        
        if (IOServiceGetMatchingServices(iomasterport,batteryMatchDictionary,&iterator)==kIOReturnSuccess){
            
            
            ioregHID()
        }
        
        return ;
    }
    
    func ioregHID(){
        
        // CFDictionaryGetValue
        
        IOIteratorReset(iterator);
        

        
        devices_name.removeAll()
        batterylevel.removeAll()
        devices_serialno.removeAll()
        status_flag.removeAll()
        
        
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
            #if DEBUG
              //  print(String(format:"AppleDeviceManagementHIDEventService Devices: %s found. path in IOService plane = %s\n",devName, pathName));
            #endif
                int8Pointer.deinitialize()
                int8NamePointer.deinitialize()
                devName.deinitialize()
                pathName.deinitialize()
            
                
            
            
            
            
            //   IORegistryEntryGetPath(io, kIOUSBPlane, pathName);
            //   printf("Device's path in IOUSB plane = %s\n", pathName);
            
            var child:Unmanaged<CFMutableDictionary>?
            
            IORegistryEntryCreateCFProperties(io, &child, kCFAllocatorDefault, 0)
            //   IORegistryEntryGetChildIterator(io,kIOServicePlane,&child)
            
            let childdict = NSDictionary(dictionary:(child?.takeUnretainedValue())!)
            
            if let batterypercentage  = childdict["BatteryPercent"] {
                batterylevel.append(Int(truncating: batterypercentage as! NSNumber))
            }else{
                continue
            }
            
            devices_name.append(childdict["Product"] as! String)
            
            if let serialno  = childdict["SerialNumber"] {
                devices_serialno.append(serialno as! String)
            }else{
                devices_serialno.append("")
            }
            
            if let flags  = childdict["BatteryStatusFlags"] {
                status_flag.append(Int(truncating: flags as! NSNumber))
            }else{
                status_flag.append(0)
            }
            
            
            child?.release()
            
            IOObjectRelease(io)

            

            
        }while(IOIteratorIsValid(iterator)==boolean_t(truncating: true))
        
        
        NotificationCenter.default.post(name:Notification.Name(rawValue:IOHID.updatenotify),object:nil)
        
        
        
    
    }
    
    

    
    
    
    
    
    func startTimer() {
        let labelid = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
        let queue = DispatchQueue(label: (labelid! + "." + String(describing: type(of: self))), attributes: .concurrent)
        
        timer?.cancel()        // cancel previous timer if any
        
        timer = DispatchSource.makeTimerSource(queue: queue)
        
        timer?.schedule(deadline: .now(), repeating: .seconds(interval), leeway: .seconds(1))
        
        timer?.setEventHandler { // `[weak self]` only needed if you reference `self` in this closure and you want to prevent strong reference cycle
            
            
            self.update()
            
            
        }
        
        timer?.resume()
    }
    
    func stopTimer() {
        timer?.cancel()
        timer = nil
    }
    
    private func update(){
        
        updating = true
        
        updateHID()
        
        updating = false
        
        
    }
    
    
    
}
