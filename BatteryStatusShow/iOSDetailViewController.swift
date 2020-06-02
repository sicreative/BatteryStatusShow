//
//  iOSDetailViewController.swift
//  BatteryStatusShow
//
//  Created by slee on 2017/5/28.
//  Copyright © 2017年 sicreativelee. All rights reserved.
//


import Cocoa

class IOSDetailViewController: BatteryViewController {
    
    @IBOutlet weak var iOSSerialno: NSTextField!
    @IBOutlet weak var iOSName: NSTextField!
    @IBOutlet var detailviewoutlet: NSView!
    @IBOutlet weak var status: NSTextField!
    @IBOutlet weak var iOSColor: NSTextFieldCell!
    @IBOutlet weak var iOSDesc: NSTextField!
    @IBOutlet weak var estimatedText: NSTextField!
 
    @IBOutlet weak var manufdateText: NSTextField!
    
    @IBOutlet weak var voltageText: NSTextField!
    
    @IBOutlet weak var adaptorView: NSView!
    
    
    @IBOutlet weak var adaptorNameText: NSTextField!
    @IBOutlet weak var adaptorVoltageText: NSTextField!
    @IBOutlet weak var adaptorAmperageText: NSTextField!
    @IBOutlet weak var adaptorWattText: NSTextField!
    
    @IBOutlet weak var batteryPercentIndicator: NSLevelIndicator!
    @IBOutlet weak var batterypercentText: NSTextField!
    @IBOutlet weak var capacityFullText: NSTextField!
    @IBOutlet weak var powerText: NSTextField!
    @IBOutlet weak var serialText: NSTextField!
    @IBOutlet weak var cycleText: NSTextField!
    @IBOutlet weak var avgpowerText: NSTextField!
    @IBOutlet weak var temperatureText: NSTextField!
    @IBOutlet weak var manfText: NSTextField!
    @IBOutlet weak var currentText: NSTextField!
    @IBOutlet weak var capacityText: NSTextField!
    @IBOutlet weak var modelText: NSTextField!
    
    
    
    

    
    var count = 0;
    
    var updatedesc = true;
    
    
    
    
    
    
    
    
    override func updatebatteryinfo(){
        
        //iobattery = (NSApplication.shared().delegate as! AppDelegate).iobattery
        
        
        
        
        
        if (iobattery != nil ){
            // iobattery.updatebattery()
            
            
          
           // detailviewoutlet.isHidden = false;
            
            //voltage = iobattery.voltage.description
            voltageText.stringValue = iobattery.iosVoltage.description + " v"
            
            currentText.stringValue = (iobattery.iosAmperage > 0 ? "⬆︎ ": iobattery.iosAmperage < 0 ? "⬇︎ ":"  ") + abs(iobattery.iosAmperage).description + " ma"
            
            
            capacityText.stringValue = iobattery.iosCurrentCapacity.description + " mah"
            capacityFullText.stringValue = String(format:"%@ / %@ (%.1f %%)",iobattery.iosMaxCapacity.description,iobattery.iosDesignCapacity.description,iobattery.iosbatteryhealthpercent())
            
            cycleText.stringValue = String(format:"%@ ",iobattery.iosCycle.description)
            
            temperatureText.stringValue = iobattery.iosBatteryTemp.description + " °C"
            
            let power = iobattery.iospower()
            
            powerText.stringValue = (power > 0 ? "⬆︎ ": power < 0 ? "⬇︎ ":"  ") + String(format:"%.2f w",abs(power))
            
            batterypercentText.stringValue = String(format:"%.1f %%",iobattery.iosbatterypercentage())
            
            if (count==0){
                avgpowerText.stringValue =  (power > 0 ? "⬆︎ ": power < 0 ? "⬇︎ ":"  ") + String(format:"%.2f w",abs(power))
                
            }else{
                let avgvalue = Float(avgpowerText.stringValue)! / Float(count) * Float(count-1) +
                power / Float(count)
                
                 avgpowerText.stringValue =  (avgvalue > 0 ? "⬆︎ ": avgvalue < 0 ? "⬇︎ ":"  ") + String(format:"%.2f w",abs(avgvalue))
                
            }
            
            
            
            
            batteryPercentIndicator.intValue = Int32(iobattery.iosbatterypercentage())
            
            
            
            if (iobattery.iosIsCharging){
                status.textColor = NSColor(red: 0.45,green: 0.32,blue: 0.70,alpha: 1.0)
                status.stringValue = "Charging"
            
                
                /*
                if (iobattery.iosTimeRemaining != 0 ){
                    
                    
                    
                    let hour = Int(iobattery.iosTimeRemaining / 60)
                    
                    let min = Int(iobattery.iosTimeRemaining % 60)
                    
                    
                    
                    estimatedText.stringValue = String(format:"%d:%02d",hour,min)
                }else{
                    estimatedText.stringValue = ""
                }*/

                
          
            }else {
                status.textColor = NSColor(red: 0.5,green: 0.5,blue: 0.5,alpha: 1.0)
                status.stringValue = "use Power"
               // estimatedText.stringValue = ""
            }
            
           
            
          
            
            
            // voltageText.stringValue = iobattery.voltage.description
        }
    
    }
    
    override func updatebatterydesc(){
        // iobattery = (NSApplication.shared().delegate as! AppDelegate).iobattery
        
        
        
        
        
        if (iobattery.withIOSDevice){
            
            
            modelText.stringValue = iobattery.iosModel
            serialText.stringValue = iobattery.iosBatterySerialNumber
            manfText.stringValue = iobattery.iosManufacturer
            
            
            
      
                iOSColor.backgroundColor = iobattery.iosdevicecolor
                iOSName.stringValue = iobattery.iosproductname
                iOSName.sizeToFit()
                iOSDesc.stringValue = iobattery.iosproductversion   + "   ("+iobattery.iosproducttype+")"
                iOSDesc.sizeToFit()
            
            iOSSerialno.stringValue = "("+iobattery.iosserialno+")"
            iOSSerialno.sizeToFit()
                
            manufdateText.stringValue = iobattery.iosmanufdate
            manufdateText.sizeToFit()
            
                
            iOSSerialno.stringValue = "("+iobattery.iosserialno+")"
            iOSSerialno.sizeToFit()
     
            
            

            
           
                adaptorView.isHidden = false
                adaptorNameText.stringValue = iobattery.iosAdapterDesc
                adaptorVoltageText.stringValue = String(format:"%f v",iobattery.iosAdapterVoltage)
                adaptorAmperageText.stringValue = iobattery.iosAdapterAmperage.description + "ma"
                adaptorWattText.stringValue = iobattery.iosAdapterWatts.description
       
            
            
    
            
            
            
            
            //predictedlife()
            
            
            
             updatedesc = false
            
        }
        
        
    }
    
    

    
    
    
    
   
    
    

    
    
    
    
    override func update(){
        
        if (detailviewoutlet==nil){
            return
        }
        
        if (iobattery==nil){
            DispatchQueue.main.async{
                self.iobattery = (NSApplication.shared.delegate as! AppDelegate).getBattery()
            }
        }
        
        if (iobattery != nil && !iobattery.withIOSDevice){
            DispatchQueue.main.async {
            self.view.isHidden = true;
            self.updatedesc = true
            }
            
         //   detailviewoutlet.isHidden = false;

            
           
        }else{
           
        
            if (iobattery != nil && Int(iobattery.iosUpdateTime) > Int(truncating: lastupdate) ){
             self.lastupdate =   NSNumber(integerLiteral: self.iobattery.iosUpdateTime)
            DispatchQueue.main.async {
                 self.view.isHidden = false;
                self.updatebatteryinfo()
            
                if (self.updatedesc){
                    self.updatebatterydesc()
                   
                }
               

            }
        }
        
        DispatchQueue.main.async {
            self.updateview()
        }
        }
        
        
    }
}









   
