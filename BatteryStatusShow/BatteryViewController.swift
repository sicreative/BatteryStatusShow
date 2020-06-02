//
//  BatteryViewController.swift
//  BatteryStatusShow
//
//  Created by slee on 2017/5/11.
//  Copyright © 2017年 sicreativelee. All rights reserved.
//

import Cocoa

class BatteryViewController: NSViewController {
    

    
    var iobattery:IOBattery!
    var datacontroller:DataController!
    
    

    var lastupdate:NSNumber = 0
    
    
    
    
    
    var timer: DispatchSourceTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector:#selector(BatteryViewController.update), name: NSNotification.Name(rawValue:IOBattery.updatenotify), object: nil)

        self.view.window?.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.floatingWindow)))
      
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear() {
        
        super.viewDidAppear()
        datacontroller = (NSApplication.shared.delegate as! AppDelegate).getDataController()
    
        update()
        updatebatterydesc()
        

        
        
    }
    
    override func viewWillDisappear() {
        // NotificationCenter.default.removeObserver(self)
        super.viewWillDisappear()
      
    }
    
   
    
   
    /*
    
    public func startTimer() {
        let labelid = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
        let queue = DispatchQueue(label: (labelid! + "." + String(describing: type(of: self))), attributes: .concurrent)
        
        timer?.cancel()        // cancel previous timer if any
        
        timer = DispatchSource.makeTimerSource(queue: queue)
        
        timer?.scheduleRepeating(deadline: .now(), interval: .seconds(interval), leeway: .seconds(1))
        
        timer?.setEventHandler { // `[weak self]` only needed if you reference `self` in this closure and you want to prevent strong reference cycle
            
            
            self.update()
            
            
        }
        
        timer?.resume()
    }
    
    public func stopTimer() {
        timer?.cancel()
        timer = nil
    }
 */
    
    @objc func update(){
        
  
     
        if (iobattery==nil){
          
        
             DispatchQueue.main.async{
                self.iobattery = (NSApplication.shared.delegate as! AppDelegate).getBattery()
                self.updatebatterydesc()
            }
              
        }
        DispatchQueue.main.async{
            if (Int(truncating: self.iobattery.lastupdatetime) > Int(truncating: self.lastupdate) ){
            
            

                self.updatebatteryinfo()
                
               
            
                self.lastupdate = self.iobattery.lastupdatetime
                
                 
            }
            
            
        }
        
    DispatchQueue.main.async{
        self.updateview()
        }
        
    }
    
    func updateview(){
        
    }
    
    func updatebatteryinfo(){
        
        
    }
    
    func updatebatterydesc(){
        
        
        
        
    }
    
    
    
    
    override var representedObject: Any? {
        didSet {
            
            // Update the view, if already loaded.
            
            
            
        }
    }
    
    
    
    func setIOBattery(_ iobattery:IOBattery){
        self.iobattery = iobattery
        
       // self.iobattery = (NSApplication.shared.delegate as! AppDelegate).getBattery();
        
        
        
        
    }
    
    
}

