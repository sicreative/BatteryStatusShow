//
//  AppDelegate.swift
//  BatteryStatusShow
//
//  Created by slee on 2017/5/10.
//  Copyright © 2017年 sicreativelee. All rights reserved.
//

import Cocoa





@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    static let programprefix = "sicreativelee.batterystatusshow"
    
     static let user_default_alwayontop_key = "alwayontop"
    static let alwayontop_notify = AppDelegate.programprefix + ".alwayontopnotify"

    @IBAction func linkHomePage(_ sender: Any) {
        if let url = URL(string: "https://github.com/sicreative/BatteryStatusShow"), NSWorkspace.shared.open(url) {
            
        }
    }
  
    @IBOutlet weak var alwaysOnTopMenu: NSMenuItem!
    


 var batterystatus = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    var windowscontroller : NSWindowController!
    var iobattery : IOBattery!
    var datacontroller : DataController!
    var ioHID : IOHID!
    var batterystatusitem : BatteryStatusItem!
    
    @IBAction func alwaysOnTopMenuAction(_ sender: NSMenuItem) {
        
       sender.state = NSControl.StateValue(rawValue: sender.state.rawValue == 0 ? 1 : 0)
        
            UserDefaults.standard.set(sender.state,  forKey: AppDelegate.user_default_alwayontop_key)
        
         NotificationCenter.default.post(name:Notification.Name(rawValue:AppDelegate.alwayontop_notify),object: nil,userInfo:nil)
        
        
        
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
       
        
       
        
        
      
   
       startApplication()
        
   
     
        
    
        
       
       
        
    }
    
    func startApplication(){
        
        datacontroller = DataController(completionClosure: self.datacontrollerfinished);
    }
    
    

    
    func datacontrollerfinished(){
        
        if #available(OSX 10.12.2, *) {
            NSApplication.shared.isAutomaticCustomizeTouchBarMenuItemEnabled = true
        }

        
        
        batterystatusitem = BatteryStatusItem()
        
        updatestatusbutton(chargestatus:.nobattery, batterylevel: 3)
        
        if let button = batterystatus.button {
            
        
            
            // button.image = NSImage(named: "Status")
            button.action = #selector(openmainwindows(sender:))
            
        }
        
           iobattery = IOBattery()
        
        let storyboard = NSStoryboard.init(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        windowscontroller = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "mainwindowcontroller")) as? NSWindowController
        
        
      
  NSApplication.shared.activate(ignoringOtherApps: true)
        
        openmainwindows(sender: self)
        
     
        
        

        
        iobattery.startTimer()
        
        ioHID = IOHID()
        
        ioHID.startTimer()
        
    
        
        
       alwaysOnTopMenu.state = NSControl.StateValue(rawValue: UserDefaults.standard.integer(forKey: AppDelegate.user_default_alwayontop_key))
        
       
        
        
    
        
        
        /*
        
        (storyboard.instantiateController(withIdentifier: "detailviewcontroller") as! DetailViewController).setIOBattery(iobattery)
        
        (storyboard.instantiateController(withIdentifier: "iosdetailviewcontroller") as! IOSDetailViewController).setIOBattery(iobattery)
        

        

        
        (storyboard.instantiateController(withIdentifier: "peripheralviewcontroller") as! PeripheralViewController).ioHID = ioHID
        */

    
        
        
        
     
        
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
         UserDefaults.standard.set(false, forKey: "NSFullScreenMenuItemEverywhere")
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        
        iobattery.stopTimer()
        ioHID.stopTimer()
   
     
        
        
        
        
    
    
    }
    
    @objc func openmainwindows(sender: AnyObject){
      
  
        
        if (windowscontroller == nil){
        let storyboard = NSStoryboard.init(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
            windowscontroller = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "mainwindowcontroller")) as? NSWindowController
        }
      
        
     
       windowscontroller.showWindow(sender)
       
        
       
        
        
    }
    

    
    
    func getBattery()->IOBattery{
        if (iobattery==nil){
            iobattery = IOBattery()
        }
        return iobattery
    }
    
    func getDataController()->DataController{
        return datacontroller
    }
    
    func updatestatusbutton(chargestatus:BatteryStatusItem.ChangeStatus,batterylevel:Int){
        if let button = batterystatus.button {
        if( batterystatusitem.updatelogo(chargestatus: chargestatus, batterylevel: batterylevel)){
            button.image = batterystatusitem.image
            }
        }
        
    }
    
   
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) ->Bool{
      //datacontrollerfinished()
        
        if (datacontroller==nil){
            startApplication()
            return true
        }
        
        if (iobattery==nil){
            startApplication()
            return true
        }
            
        iobattery.startTimer()
        ioHID.startTimer()
        
         openmainwindows(sender: self)
        
        return true;
    }
    
    
    
    
    
    
 


}


