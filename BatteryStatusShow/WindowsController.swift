//
//  WindowsController.swift
//  BatteryStatusShow
//
//  Created by slee on 2017/6/5.
//  Copyright © 2017年 sicreativelee. All rights reserved.
//

import Cocoa

@available(OSX 10.12.2, *)
fileprivate extension NSTouchBar.CustomizationIdentifier {
    
    static let touchBar = NSTouchBar.CustomizationIdentifier( AppDelegate.programprefix + ".touchBar")
}

@available(OSX 10.12.2, *)
fileprivate extension NSTouchBarItem.Identifier {
    
    @available(OSX 10.12.2, *)
    static let tab = NSTouchBarItem.Identifier( AppDelegate.programprefix + ".tab")

}


@available(OSX 10.12.2, *)
fileprivate extension NSTouchBarItem.Identifier {
    

}

extension WindowController: NSTouchBarDelegate {
    
    
    
    
    @available(OSX 10.12.2, *)
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        
        switch identifier {
            
        case NSTouchBarItem.Identifier.tab:
            

            
     
            
            let tabStyleItem = NSCustomTouchBarItem(identifier: identifier)
            tabStyleItem.customizationLabel = "Tab Selector"


            
            
            tabStyleItem.view = gettabStyleSegment()
            
            
      
            
            return tabStyleItem;
            

            
        default: return nil
        }
    }
}




class WindowController: NSWindowController {
    
    var iobattery:IOBattery!
    var iohid:IOHID!
    
    
     static let touchbarchangednotify = AppDelegate.programprefix + ".touchbarchangednotify"
    
    
    
    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {
        
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.customizationIdentifier = .touchBar
        touchBar.defaultItemIdentifiers = [.tab]
        touchBar.customizationAllowedItemIdentifiers = [.tab]
        
        return touchBar
    }
    
    @objc func changetab(_ sender: NSSegmentedControl) {
        
        let selected = sender.selectedSegment
        
        NotificationCenter.default.post(name:Notification.Name(rawValue:WindowController.touchbarchangednotify),object: nil,userInfo:["touchbarselected":selected])
        
        
       // let style = sender.selectedSegment
       // self.setTextViewFont(index: style)
    }
    
    @objc func tabchanged(_ aNotification: Notification) {
        
        if #available(OSX 10.12.2, *) {
            
         
            (touchBar?.item(forIdentifier: .tab)?.view as! NSSegmentedControl).setSelected(true, forSegment: aNotification.userInfo?["tabselected"] as! Int)
           
        }
        
    }
    
    override func windowWillLoad() {
        
        guard #available(OSX 10.12.2, *) else {
            
            return;
            
        }


        NotificationCenter.default.addObserver(self, selector: #selector(WindowController.tabchanged), name: NSNotification.Name(rawValue: TabViewController.tabselectnotify), object: nil)
        
        NotificationCenter.default.addObserver(self, selector:#selector(WindowController.update), name: NSNotification.Name(rawValue:IOBattery.updatenotify), object: nil)
        
         NotificationCenter.default.addObserver(self, selector:#selector(WindowController.update), name: NSNotification.Name(rawValue:IOHID.updatenotify), object: nil)
    }
    
    @objc func update(){
        
       
      
            if #available(OSX 10.12.2, *) {
                DispatchQueue.main.async {
                    self.touchBar = nil
                }
               
                                 
                
            }
        }
       
    
    
    @available(OSX 10.12.2, *)
    func settabtext()->NSSegmentedControl{
        if (self.iobattery==nil){
            
            self.iobattery = (NSApplication.shared.delegate as! AppDelegate).getBattery()
            
        }
       
        
     
        
        
  
            
        
    
    
    
        
      

        var mactext = "💻"
        var iostext = "📱"
        
        if (self.iobattery != nil ){
            if (!self.iobattery.nobattery){
            mactext += " " + self.iobattery.capacity.description + "/" + self.iobattery.max_capacity.description
            }
            if (self.iobattery.withIOSDevice){
                 iostext += " " + self.iobattery.iosCurrentCapacity.description + "/" + self.iobattery.iosMaxCapacity.description
            }
        }
        
    
        var peripheraltext = "🖱"
        
        if (self.iohid==nil){
            
            self.iohid = (NSApplication.shared.delegate as! AppDelegate).ioHID
            
            
        }
        
        if (self.iohid != nil && self.iohid.batterylevel.count>0){
            for item in self.iohid.devices_name {
                if (item.range(of:"Mouse") != nil){
                    peripheraltext += " " + String( self.iohid.batterylevel[self.iohid.devices_name.index(of: item)!]) + "%"
                    break;
                }
            }
        }
        
        let graphtext = "📈"
        let lottext = "🖌"
       
       /*
                self.tabStyleSegment.setLabel(mactext, forSegment: 0)
                self.tabStyleSegment.setLabel(graphtext, forSegment: 1)
                self.tabStyleSegment.setLabel(iostext, forSegment: 2)
                self.tabStyleSegment.setLabel(peripheraltext, forSegment: 3)
                self.tabStyleSegment.setLabel(lottext, forSegment: 4)
            
         */
        
        
       return NSSegmentedControl(labels: [mactext,graphtext,iostext,peripheraltext,lottext], trackingMode: .momentary, target: self, action: #selector(changetab))
        
        
        
        

       
        
        
        
       
    }
    
    @available(OSX 10.12.2, *)
    func gettabStyleSegment()->NSSegmentedControl{
        
        
     
        
   
        
      //  let tabStyleSegment = NSSegmentedControl(labels: ["💻"+mactext,"📈","📱"+iostext,"🖱"+peripheraltext,"🖌"], trackingMode: .momentary, target: self, action: #selector(changetab))
        
       //  var tabStyleSegment = NSSegmentedControl(labels: ["💻","📈","📱","🖱","🖌"], trackingMode: .momentary, target: self, action: #selector(changetab))x
        
        
        
       let tabStyleSegment = settabtext()
        
        tabStyleSegment.setSelected(true, forSegment: 1)
        
        tabStyleSegment.segmentStyle = NSSegmentedControl.Style.rounded
        
      tabStyleSegment.trackingMode = .selectOne
        
        return tabStyleSegment
        
    }
 

}
