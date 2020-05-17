//
//  TabViewController.swift
//  BatteryStatusShow
//
//  Created by slee on 2017/5/28.
//  Copyright © 2017年 sicreativelee. All rights reserved.
//

import Cocoa

class TabViewController : NSTabViewController {
    
    static let tabselectnotify = AppDelegate.programprefix + ".tabselectnotify"
    
    override func viewDidLoad() {
        super.viewDidLoad()
         let storyboard = NSStoryboard.init(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let iostabviewitem =  NSTabViewItem()
        iostabviewitem.label = "IOS"
        iostabviewitem.image = NSImage(named:NSImage.Name(rawValue: "Iphone"))
        
        iostabviewitem.viewController =  (storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "iosdetailviewcontroller")) as! IOSDetailViewController)
        self.addTabViewItem(iostabviewitem)
        
        let peripheraltabviewitem =  NSTabViewItem()
        peripheraltabviewitem.label = "Peripheral"
        peripheraltabviewitem.image = NSImage(named:NSImage.Name(rawValue: "Mouse"))
        peripheraltabviewitem.viewController =  (storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "peripheralviewcontroller")) as! PeripheralViewController)
        self.addTabViewItem(peripheraltabviewitem)
        
        
        let logviewitem =  NSTabViewItem()
        logviewitem.label = "Log"
        logviewitem.image = NSImage(named:NSImage.Name(rawValue: "Log"))
        logviewitem.viewController =  (storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "logviewcontroller")) as! LogViewController)
        self.addTabViewItem(logviewitem)
        
      
        addObserver(self, forKeyPath: "selectedTabViewItemIndex", options: [.new,.initial], context: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TabViewController.touchbarchange), name: NSNotification.Name(rawValue: WindowController.touchbarchangednotify), object: nil)
        
          NotificationCenter.default.addObserver(self, selector: #selector(TabViewController.alwayontopchange), name: NSNotification.Name(rawValue: AppDelegate.alwayontop_notify), object: nil)
        
       
          
            self.addObserver(self, forKeyPath: "view.window", options: [.new, .initial], context: nil)
        
        alwayontopchange()
        
        
   
    }
    
    @objc func touchbarchange(_ aNotification:Notification){
        DispatchQueue.main.async {
            self.selectedTabViewItemIndex = aNotification.userInfo?["touchbarselected"] as! Int
        }
    }
    
    
    
    @objc func alwayontopchange(){
        DispatchQueue.main.async{ 
            if let window = self.view.window {
            if (UserDefaults.standard.integer(forKey: AppDelegate.user_default_alwayontop_key)==1){
                window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(CGWindowLevelKey.floatingWindow)))
            }else{
                window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(CGWindowLevelKey.normalWindow)))
                // window.level = Int(CGWindowLevelForKey(CGWindowLevelKey.floatingWindow))
            }
            }
        }
    }
    
 
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //print("CHANGE OBSERVED: \(String(describing: change))")
        if (keyPath == "selectedTabViewItemIndex"){
            
            NotificationCenter.default.post(name:Notification.Name(rawValue:TabViewController.tabselectnotify),object: nil,userInfo:["tabselected":change?[NSKeyValueChangeKey.newKey] as Any])
            
        } else if (keyPath == "view.window"){
        if let window = self.view.window {
            
            window.tabbingMode = .disallowed
            
            
            // custom window here
            if (UserDefaults.standard.integer(forKey: AppDelegate.user_default_alwayontop_key)==1){
                   window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(CGWindowLevelKey.floatingWindow)))
                }else{
                    window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(CGWindowLevelKey.normalWindow)))
               // window.level = Int(CGWindowLevelForKey(CGWindowLevelKey.floatingWindow))
                }
            }
        }
    }
    

    
    
    
    
    
    
}
