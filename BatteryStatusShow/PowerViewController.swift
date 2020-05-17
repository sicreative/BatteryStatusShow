//
//  PowerViewController.swift
//  BatteryStatusShow
//
//  Created by slee on 2017/5/17.
//  Copyright © 2017年 sicreativelee. All rights reserved.
//

import Cocoa

class PowerViewController: BatteryViewController {
    
    var totalshowmins = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        (view as! BaseChartView).title.stringValue = "Power"
        (view as! BaseChartView).title.sizeToFit()
        
        (view as! BaseChartView).ytitle.stringValue = "Watt"
        (view as! BaseChartView).ytitle.sizeToFit()
        
        (view as! BaseChartView).xtitle.stringValue = "mins"
        (view as! BaseChartView).xtitle.sizeToFit()
        
        (view as! TwoAxisBaseChartView).righttitle.stringValue = "voltage"
        (view as! TwoAxisBaseChartView).righttitle.sizeToFit()
        
        
        
    
        (view as! BaseChartView).maxmindecimal = 2
        (view as! BaseChartView).showmaxmin = true
        
        (view as! TwoAxisBaseChartView).rightmaxmindecimal = 2
      
        
        
        
        // Do any additional setup after loading the view.
    }
    
    
   
    
    
    
    override func updateview() {
        
        let nowtime = Date()
        let firstshowtime = (Calendar.current).date(byAdding: .minute, value: -totalshowmins, to: nowtime)
        
        //skill out of time item
  
            
        
            
        let sorted = iobattery.batteryrecord.sorted(by: {a,b in a.key > b.key})
        var records:Array<IOBattery.IOBatteryRecord> = Array<IOBattery.IOBatteryRecord>()
        
        for item in sorted{
            
            
            if (iobattery.ischarge && item.value.current < 0){
                
                break
            }
            
            if (!iobattery.ischarge && item.value.current > 0){
                break
            }
            
            records.append(item.value)
         
            
                
            if (item.key <= Int(firstshowtime!.timeIntervalSince1970)){
                break
            }
            
         
            
           
            
          
    
            
          
            
            
            
           
                
        }
            
        
        
        
      
   
        
        if (iobattery.ischarge){
           
            (view as! BaseChartView).chartlinecolor =
                CGColor(red:0.8,green:0.2,blue:0.2,alpha:0.95)
             (view as! BaseChartView).title.stringValue = "Power (Charge)"
            
            
        }else if (iobattery.withcharger){
            (view as! BaseChartView).chartlinecolor =
                CGColor(red:0.1,green:0.1,blue:0.8,alpha:0.95)
            (view as! BaseChartView).title.stringValue = "Power (With Charger)"
            
        }else{
            (view as! BaseChartView).chartlinecolor =
                CGColor(red:0.1,green:0.1,blue:0.8,alpha:0.95)
            (view as! BaseChartView).title.stringValue = "Power (DisCharge)"

        }
        (view as! BaseChartView).title.sizeToFit()
        
        if (records.count == 0){
            return
        }
        
        //var watt = iobattery.voltage * Float(iobattery.amperage)/1000
        let maxitem = records.max(by: {a,b in (Float(abs(a.current)) * a.voltage) < (Float(abs(b.current)) * b.voltage) })
        
        var watt = maxitem!.voltage * Float(abs(maxitem!.current)) / 1000
        
        
        if (watt < 8){
            watt = 8
        }else{
            let remainder = watt.truncatingRemainder(dividingBy: 4)
            watt -= remainder
            watt += 4
            
        }
        
        (view as! BaseChartView).rowstep = Int (watt) / 4
        (view as! BaseChartView).rowinit = Int (watt) / 4
        
        
         let maxvoltageitem = records.max(by: {a,b in a.voltage <  b.voltage })
        
        // Macbook Pro with Voltage heighter that 10
      
            let voltageremainer = maxvoltageitem!.voltage.truncatingRemainder(dividingBy: 2)
        
        (view as! TwoAxisBaseChartView).rightrowinit = Int (maxvoltageitem!.voltage - voltageremainer - Float(2))
        
   
        
          (view as! TwoAxisBaseChartView).rightrowstep = 2
    
        
     
        
        
        
        (view as! BaseChartView).linechart.removeAll()
         (view as! TwoAxisBaseChartView).rightlinechart.removeAll()
        
        
        let rightvoltagemin:Float =  Float ((view as! TwoAxisBaseChartView).rightrowinit -  (view as! TwoAxisBaseChartView).rightrowstep)
     
        

        
        for item in records{
            
       
                
              //  print(String(format:"key = %d, %d firshowtime",item.timestamp,Int(firstshowtime!.timeIntervalSince1970)))
                
                let x = CGFloat( (Double(item.timestamp)-firstshowtime!.timeIntervalSince1970)/(nowtime.timeIntervalSince1970 - firstshowtime!.timeIntervalSince1970))
                
                let y = CGFloat((item.voltage * Float(abs(item.current))) / (watt*1000))
            
                (view as! BaseChartView).linechart.append(CGPoint(x:x,y:y))
            
             let right = Float((item.voltage - rightvoltagemin) / Float((view as! TwoAxisBaseChartView).rightrowstep * 4  ))
            
                (view as! TwoAxisBaseChartView).rightlinechart.append(CGPoint(x:x,y:CGFloat(right)))
        
            }
        
        //Alighment of right edge
        if ((view as! BaseChartView).linechart.count >= 1){
            (view as! BaseChartView).linechart[0].x = 1;
       
        
        
   
        
        //Alighment of left edge
        
        
        
        if ((view as! BaseChartView).linechart[(view as! BaseChartView).linechart.count-1].x<0){
            
              let a = (view as! BaseChartView).linechart[(view as! BaseChartView).linechart.count-1]
            let b = (view as! BaseChartView).linechart[(view as! BaseChartView).linechart.count-2]
            let slope = (a.y - b.y) / (a.x - b.x)
            
            // y = mx + b
          (view as! BaseChartView).linechart[(view as! BaseChartView).linechart.count-1].y = b.y - slope * b.x
            
            
            
            (view as! BaseChartView).linechart[(view as! BaseChartView).linechart.count-1].x = 0
            
            
        }
            
             }
        
        if ((view as! TwoAxisBaseChartView).rightlinechart.count>=2){
            (view as! TwoAxisBaseChartView).rightlinechart[0].x = 1;
        }
        
        if ((view as! TwoAxisBaseChartView).rightlinechart.count>=1 &&
        (view as! TwoAxisBaseChartView).rightlinechart[(view as! BaseChartView).linechart.count-1].x<0){
            
            if (view as! TwoAxisBaseChartView).rightlinechart.count>1{
                
           
            
            
            
            let a = (view as! TwoAxisBaseChartView).rightlinechart[(view as! BaseChartView).linechart.count-1]
            let b = (view as! TwoAxisBaseChartView).rightlinechart[(view as! BaseChartView).linechart.count-2]
            let slope = (a.y - b.y) / (a.x - b.x)
            
            // y = mx + b
            (view as! TwoAxisBaseChartView).rightlinechart[ (view as! TwoAxisBaseChartView).rightlinechart.count-1].y = b.y - slope * b.x
            
            
            }
            (view as! TwoAxisBaseChartView).rightlinechart[(view as! TwoAxisBaseChartView).rightlinechart.count-1].x = 0
            
                
        
            
        }
        
        
      
        
        
        
        
        
        
        view.layer?.setNeedsDisplay()
        view.layer?.displayIfNeeded()
        
   


        
        
    }
    
    override func updatebatterydesc() {
        (view as! BaseChartView).columnstep = -totalshowmins / 4
        (view as! BaseChartView).columninit = totalshowmins * 3 / 4
        
    }
    
    
    
}


