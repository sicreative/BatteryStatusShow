//
//  DetailViewController.swift
//  BatteryStatusShow
//
//  Created by slee on 2017/5/11.
//  Copyright © 2017年 sicreativelee. All rights reserved.
//

import Cocoa



class DetailViewController: BatteryViewController {
  
    @IBOutlet var detailviewoutlet: NSView!
    @IBOutlet weak var status: NSTextField!
    @IBOutlet weak var estimatedText: NSTextField!
    @IBOutlet weak var healthText: NSTextField!
    @IBOutlet weak var voltageText: NSTextField!
  
    @IBOutlet weak var manufDateText: NSTextField!
    @IBOutlet weak var adaptorView: NSView!
    @IBOutlet weak var macSerialNoText: NSTextField!
  
    @IBOutlet weak var macNameText: NSTextField!
    @IBOutlet weak var macDescText: NSTextField!

    @IBOutlet weak var adaptorNameText: NSTextField!
    @IBOutlet weak var adaptorManfText: NSTextField!
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
    @IBOutlet weak var chargelevelText: NSTextField!
    
    @IBOutlet weak var chargeLevelButton: NSButton!
    
    var middletextfield : NSTextField!
    
    @objc func changevalue(sender:NSSlider){
    
        DispatchQueue.main.async {
            
            self.middletextfield!.stringValue = String(sender.intValue)
            self.middletextfield.sizeToFit()
        }
       
    }
  
    @IBAction func changeChangeLevel(_ sender: NSButton) {
        
        let alert = NSAlert()
        
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "OK")
        
        let slider = NSSlider()
        slider.maxValue = 100
        slider.minValue = 40
        
        
        slider.frame.size.width = 200
        slider.frame.size.height = 50
        slider.altIncrementValue = 1
        
      //  let mintextfield =
        
        let mintextfield = NSTextField(labelWithString: String(Int(slider.minValue)));
        let maxtextfield = NSTextField(labelWithString: String(Int(slider.maxValue)));
        var x = (NSWidth(slider.bounds) - maxtextfield.frame.size.width);
        var y = CGFloat(0)
        let maxtextframe = CGRect(x: x, y: y, width: maxtextfield.frame.size.width, height: maxtextfield.frame.size.height)
        maxtextfield.frame = maxtextframe
        slider.addSubview(mintextfield)
        slider.addSubview(maxtextfield)
        middletextfield = NSTextField(labelWithString: iobattery.chargelevel);
     
        
        x = (NSWidth(slider.bounds) - maxtextfield.frame.size.width) * 0.5
        y = (NSHeight(slider.bounds) - middletextfield.frame.size.height)
        let middleframe = CGRect(x: x, y: y, width: middletextfield.frame.size.width, height: middletextfield.frame.size.height)
        middletextfield.frame = middleframe
        slider.addSubview(middletextfield)
        slider.intValue = Int32(iobattery.chargelevel) ?? 100
        slider.action = #selector(changevalue(sender:))
        slider.target = self
        
     
        
        
        alert.accessoryView = slider
        alert.messageText = "Change of Max changing level."
        alert.informativeText = "Beware! This is for Advanced User without offical support !!!!.\nChange of SMC value (Hardware) may damage your computer,\nRESET SMC if any issue.\n\nRequire SUDO"
        alert.alertStyle = .critical
        
        
        
        alert.beginSheetModal(for: self.view.window!, completionHandler: { modalRespose in
            if (modalRespose == .alertSecondButtonReturn){
                self.iobattery.setChangeLevel(value:Int(self.middletextfield.stringValue)!)
            }
            
        } )
        
    
      
    }
    
    

    


    
    override func updatebatteryinfo(){
        
        //iobattery = (NSApplication.shared().delegate as! AppDelegate).iobattery
        
        
        if (detailviewoutlet == nil){
            return;
        }
        
        
        if (iobattery != nil){
           // iobattery.updatebattery()
            
            if (iobattery.nobattery){
                detailviewoutlet.isHidden = true;
                return
            }
            
            if (detailviewoutlet.isHidden == true){
                updatebatterydesc()
                 detailviewoutlet.isHidden = false;
            }
            
          
           
            //voltage = iobattery.voltage.description
            voltageText.stringValue = iobattery.voltage.description + " v"
            
            currentText.stringValue = (iobattery.amperage > 0 ? "⬆︎ ": iobattery.amperage < 0 ? "⬇︎ ":"  ") + abs(iobattery.amperage).description + " ma"
            
            
            capacityText.stringValue = iobattery.capacity.description + " mah"
            capacityFullText.stringValue = String(format:"%@ / %@ (%.1f %%)",iobattery.max_capacity.description,iobattery.design_capacity.description,iobattery.batteryhealthpercent())
        
            cycleText.stringValue = String(format:"%@ / %@",iobattery.cycle_count.description,iobattery.design_cycle.description)
       
            temperatureText.stringValue = iobattery.tempKtoC().description + " °C"
            
            let power = iobattery.power()
            
            powerText.stringValue = (power > 0 ? "⬆︎ ": power < 0 ? "⬇︎ ":"  ") + String(format:"%.2f w",abs(power))
            
            batterypercentText.stringValue = String(format:"%.1f %%",iobattery.batterypercentage())
        
    
            batteryPercentIndicator.intValue = Int32(iobattery.batterypercentage())
                
    
            
            if (iobattery.ischarge){
                status.textColor = NSColor(red: 0.45,green: 0.32,blue: 0.70,alpha: 1.0)
                status.stringValue = "Charging"
            }else if (iobattery.withcharger){
                status.textColor = NSColor(red: 0.5,green: 0.5,blue: 0.5,alpha: 1.0)
                status.stringValue = "use Power"
            }else {
                status.textColor = NSColor(red: 0.53,green: 0.72,blue: 0.34,alpha: 1.0)
                status.stringValue = "use Battery"

            }
            
            avgpowerText.stringValue = (iobattery.avgpower > 0 ? "⬆︎ ": iobattery.avgpower < 0 ? "⬇︎ ":"  ") + String(format:"%.2f w",abs(iobattery.avgpower))
                
                
            
            
            estimatedText.stringValue = iobattery.estimatedtime
            
            
            if (iobattery.withcharger){
                adaptorView.isHidden = false
                adaptorNameText.stringValue = iobattery.adapterDesc
                adaptorManfText.stringValue = iobattery.adapterManu
                adaptorWattText.stringValue = iobattery.adapterWatts
            }else{
                
                adaptorView.isHidden = true
            }
            
            
          
            if (iobattery.chargelevel.isEmpty){
                self.chargelevelText.stringValue = ""
                self.chargeLevelButton.isHidden = true
                
            }else{
                self.chargelevelText.stringValue = "\(iobattery.chargelevel) %"
                self.chargeLevelButton.isHidden = false
            }
            
            
            
            
           // voltageText.stringValue = iobattery.voltage.description
        }
    }
    
   override func updatebatterydesc(){
       // iobattery = (NSApplication.shared().delegate as! AppDelegate).iobattery
        
        
        
        
        
        if (iobattery != nil){
            
            
            modelText.stringValue = iobattery.device_name
            serialText.stringValue = iobattery.battery_serialno
            manfText.stringValue = iobattery.battery_manufacturer
            healthText.stringValue = iobattery.battery_status
            
     

            
            
            
            
            macNameText.stringValue = iobattery.macname + "\n" + iobattery.macmodel
            macNameText.sizeToFit()
            
            
            macDescText.stringValue = iobattery.macdesc
            macDescText.sizeToFit()
            
            macSerialNoText.stringValue = "("+iobattery.macserialno+")"
            macSerialNoText.sizeToFit()
        
            manufDateText.stringValue = iobattery.batterymanfdate
            manufDateText.sizeToFit()
        
            
           // predictedline()

                
         
            
        
        }
    
        
    }
    
    
    
    

    
            
        /*
        
        for i in 1...84 {
            
            if  (arc4random_uniform(3)==0){
               continue
            }
        
        let history = NSEntityDescription.insertNewObject(forEntityName: "History", into: datacontroller.managedObjectContext) as! HistoryMO
        
        history.capacity = (iobattery.max_capacity + i - 100 + Int(arc4random_uniform(100)) ) as NSNumber
            
             history.cycle = (iobattery.cycle_count * i / 150) as NSNumber
            
            let calendar = Calendar.current
           history.time =   calendar.date(byAdding: Calendar.Component.day, value: -i, to: Date())
        
        }*/

        
    static func exponentreg(_ x:[Double],_ y:[Double])->(A:Double,r:Double,coefficient:Double){
        var logy = [Double]()
        for item in y {
         
            logy.append(log2(item==0 ? 0.0000000000001:item))
        }
        let lreg = linearReg(x,logy)
        
        let r = pow(10,lreg.slope)
        let A = pow(10,lreg.intersection)
        
        return (A,r,lreg.coefficient)
        
        
        
    }
    
    
    static func linearReg(_ x:[Double],_ y:[Double])->(slope:Double,intersection:Double,coefficient:Double){
   
     
        var sumxy : Double = 0
        var sumx : Double = 0
        var sumy : Double = 0
        
        var sumy2  : Double = 0
        var sumx2 : Double = 0
        
        let count:Double = Double(x.count)

        
        for i in 0..<x.count {
            
            sumx += x[i]
            sumx2 += pow(x[i], 2)
            sumxy += y[i] * x[i]
            sumy += y[i]
            sumy2 += pow(y[i],2)
 
        }
        let slope = (count*sumxy-sumx*sumy) / (count*sumx2-pow(sumx,2))
  
        let intersection = (sumy - slope*sumx) / count

        let coefficient = (count * sumxy - sumx*sumy) /
            (sqrt(count*sumx2-pow(sumx,2))*sqrt(count*sumy2-pow(sumy,2)))
        
        return (slope,intersection,coefficient)
        
        
   
        
    }
    
    static func calcatepredict(x:Double,slope:Double,intersection:Double)->Double{
        return slope *  x + intersection
    }
    

    
    
   
    static func calcatedline(_ history :[HistoryMO])->(slope:Double,intersect:Double){
        

        //let mintime = history.min ( by: {a, b  in a.time! < b.time! })
        

        
      //  let minsecond : Double = mintime!.time!.timeIntervalSince1970
        
        

        var x = [Double]()
        var y = [Double]()
  
    
        for item in history {
             y.append(item.capacity as! Double)
                x.append((item.time?.timeIntervalSince1970)!)
         
        }
        
        
        let regtime = DetailViewController.linearReg(x, y)
        
        
        

        

        
        
        
        
    
    

        
        
        

        
       // sse /= count
        //ssecycle /= count
        
        
       
    
        
        
        
        
        
        
      //  let predicted80 = slope * 0.8 * Double(designcapacity) + intersection + minsecond
      //  let predicted70 = slope * 0.7 * Double(designcapacity) + intersection + minsecond
   
        
        
        return (regtime.slope,regtime.intersection)
        
    }
    


    
    
    
    
    
}
