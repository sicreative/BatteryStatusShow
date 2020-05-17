//
//  PeripheralViewControl.swift
//  BatteryStatusShow
//
//  Created by slee on 2017/5/28.
//  Copyright © 2017年 sicreativelee. All rights reserved.
//

import Cocoa


class PeripheralViewController: NSViewController {
    

    var ioHID:IOHID!
    
   
   
    
    
    var lastupdate:NSNumber = 0
  
    var timer: DispatchSourceTimer?
    
    var nameTextFields:[NSTextField] = [NSTextField]()
    var batterylevelTextFields:[NSTextField] = [NSTextField]()
    var hozlines:[NSBox]=[NSBox]()
    var updating = false;
    

    
    
    override func viewDidAppear() {
        
        super.viewDidAppear()
        NotificationCenter.default.addObserver(self, selector:#selector(BatteryViewController.update), name: NSNotification.Name(rawValue:IOHID.updatenotify), object: nil)

        
        update()
        /*
        
        NotificationCenter.default.addObserver(self, selector:#selector(BatteryViewController.update), name: NSNotification.Name(rawValue:IOBattery.updatenotify), object: nil)
        
        */
      
        
        
    }
    
    override func viewWillDisappear() {
         NotificationCenter.default.removeObserver(self)
        
      
        super.viewWillDisappear()
       
    
    }
    
    
    
    

  
    
    @objc  func update(){
          if (!updating){
            self.updating = true;
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            
                self.updateperipheral()
                self.updating = false;
            
            
            }
            
        }
        
    //    DispatchQueue.main.async
    }
 
    
    func updateperipheral(){
        
        
    
        
        if (ioHID==nil){
            if ((NSApplication.shared.delegate as! AppDelegate).ioHID != nil){
                ioHID = (NSApplication.shared.delegate as! AppDelegate).ioHID
            }else{
                (NSApplication.shared.delegate as! AppDelegate).ioHID = IOHID();
                if ((NSApplication.shared.delegate as! AppDelegate).ioHID != nil){
                    ioHID = (NSApplication.shared.delegate as! AppDelegate).ioHID
                }else{
                    return;
                }
            }

        }
        
        if (ioHID.updating){
            return
        }
        
        
      //  let viewwidth = view.bounds.width
        let viewheight =  view.bounds.height
        
        if (ioHID.batterylevel.count < hozlines.count){
            for i in ioHID.batterylevel.count..<hozlines.count{
                hozlines[i].isHidden = true
                batterylevelTextFields[i].isHidden = true
                nameTextFields[i].isHidden = true
            }
            
            
            
        }
        
        
        if (ioHID.batterylevel.count==0){
            return
        }
        
        
        for i in 0..<ioHID.batterylevel.count{
            
            var status = ""
            if (ioHID.status_flag[i]==3 && ioHID.batterylevel[i]<100){
                status = "  Charging"
            }
            if ( i > batterylevelTextFields.count-1){
                
                let hozline = NSBox()
                hozline.frame = NSMakeRect(20, CGFloat(viewheight-56.0-CGFloat(i)*25.0), 420, 5)
                hozline.title = ""
                view.addSubview(hozline)
                hozlines.append(hozline)
                
                
                
                let batterynameTextField = NSTextField();
                
                batterynameTextField.stringValue = ioHID.batterylevel[i].description + " %" + status
                batterynameTextField.frame = NSMakeRect(25, CGFloat(viewheight-52.0-CGFloat(i)*25.0), 100,100)
                
                
                
                
                batterynameTextField.backgroundColor = NSColor.controlColor
                batterynameTextField.textColor = NSColor.labelColor
                batterynameTextField.isBordered = false
                batterynameTextField.isEditable = false
                batterynameTextField.isBezeled = false
                batterynameTextField.alignment = NSTextAlignment.center
                batterynameTextField.font = NSFont(name:"Helvetica Neue Medium", size:12)
                view.addSubview(batterynameTextField)
                nameTextFields.append(batterynameTextField)
                

                
             
                
               let batterylevelTextField = NSTextField();
                
            
                
                
                batterylevelTextField.stringValue = ioHID.batterylevel[i].description + " %" + status
                 batterylevelTextField.frame = NSMakeRect(320, CGFloat(viewheight-50.0-CGFloat(i)*25.0), 100,100)
                
         
               
                
                batterylevelTextField.backgroundColor = NSColor.controlColor
                batterylevelTextField.textColor = NSColor.labelColor
                batterylevelTextField.isBordered = false
                batterylevelTextField.isEditable = false
                batterylevelTextField.isBezeled = false
                batterylevelTextField.alignment = NSTextAlignment.center
                batterylevelTextField.font = NSFont(name:"Helvetica Neue Medium", size:12)
                
                view.addSubview(batterylevelTextField)
                batterylevelTextFields.append(batterylevelTextField)
                
                
              
                
       
                
                
            }
                batterylevelTextFields[i].isHidden = false
                batterylevelTextFields[i].stringValue = ioHID.batterylevel[i].description + " %" + status
                batterylevelTextFields[i].sizeToFit()
                nameTextFields[i].isHidden = false
                nameTextFields[i].stringValue = ioHID.devices_name[i] + " (" + ioHID.devices_serialno[i] + ")"
            
                nameTextFields[i].sizeToFit()
            hozlines[i].isHidden = false
            
        }
        
       
    }
        
  
        
      
    
    
    
}
