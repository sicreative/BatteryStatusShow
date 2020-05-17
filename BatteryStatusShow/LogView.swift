//
//  LogView.swift
//  BatteryStatusShow
//
//  Created by slee on 2017/5/30.
//  Copyright © 2017年 sicreativelee. All rights reserved.
//

import Cocoa

class LogView:StatusBaseChartView {
    
    

    
    override func setdefault() {
        super.setdefault()
        
      
        

       
    }
    
    override func magnify(with event:NSEvent){
        
     
        if (event.magnification == 0){
            return
        }
        
      // Swift.print (String(format:"magnify: %f",event.magnification))
        
       let settedinterval = event.magnification * 10000         
        
         NotificationCenter.default.post(name:Notification.Name(LogViewController.magnifynotifykey), object: nil, userInfo: ["magnification":settedinterval])
        
        
    }
    
    
    override func swipe(with event: NSEvent){
      
       // Swift.print (String(format:"swipe: %f",event.deltaX))

        
    }
    
    override func scrollWheel(with event: NSEvent){
        
     //   Swift.print (String(format:"scroll: %f",event.deltaX))
        
        if (event.scrollingDeltaX != CGFloat(0)){
            
          //  Swift.print (String(format:"scrollY: %f",event.scrollingDeltaY))
            
            NotificationCenter.default.post(name:Notification.Name(LogViewController.movenotifykey), object: nil, userInfo: ["moving":event.scrollingDeltaX ])
            
            return;
        }
        

        if (event.scrollingDeltaY != CGFloat(0)){
            
  
        
            
            let settedinterval = event.scrollingDeltaY * 100
         //   Swift.print (String(format:"scrollY: %f",event.scrollingDeltaY))
        
        NotificationCenter.default.post(name:Notification.Name(LogViewController.magnifynotifykey), object: nil, userInfo: ["magnification":settedinterval])
        }
        
        

        

    }
    
  

    
    
}
