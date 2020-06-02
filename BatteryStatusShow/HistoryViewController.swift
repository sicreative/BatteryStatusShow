//
//  HistoryViewController.swift
//  BatteryStatusShow
//
//  Created by slee on 2017/5/16.
//  Copyright © 2017年 sicreativelee. All rights reserved.
//

import Cocoa

class HistoryViewController: BatteryViewController {
    
    var history: [HistoryMO]!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        (view as! BaseChartView).title.stringValue = "Battery Health"
        (view as! BaseChartView).title.sizeToFit()
        
       (view as! BaseChartView).ytitle.stringValue = "capacity"
        (view as! BaseChartView).ytitle.sizeToFit()
        
        (view as! BaseChartView).xtitle.stringValue = "months"
        (view as! BaseChartView).xtitle.sizeToFit()
        
     
        
        (view as! BaseChartView).showbelowcolor = true
        (view as! BaseChartView).showmaxmin = true
        
    
        
        
        // Do any additional setup after loading the view.
    }


  
    
    
    override func updatebatterydesc() {
        
         (view as! BaseChartView).linechart.removeAll()
     
        (view as! BaseChartView).rowstep = iobattery.design_capacity / 4
         (view as! BaseChartView).rowinit = iobattery.design_capacity / 4
        

        
      
        
        
        let historyFetch :NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "History")
        historyFetch.sortDescriptors = [NSSortDescriptor(key: "time", ascending: true)]
        
          historyFetch.predicate = NSPredicate(format:"( serialno = %@ )",iobattery.battery_serialno)
        
        do {
            if (datacontroller==nil){
                return
            }
            history = try datacontroller.managedObjectContext.fetch(historyFetch) as? [HistoryMO]
            
            var maxduration : Int = 12;
            let now = Date()
            
           
            
            let dateformatter = DateFormatter()
            dateformatter.timeZone = NSTimeZone.local
            dateformatter.dateStyle = .medium
            dateformatter.timeStyle = .medium
            
            if (history.count>0){
                
            
            var interval = history[0].time?.timeIntervalSince(now)
            let months = interval! / (-86400 * 30.4375)
            let calender = Calendar.current
            if (Int(months) > maxduration){
                maxduration = Int(months)
            }else{
                
                
                interval = calender.date(byAdding: .year, value: -1, to: now)?.timeIntervalSince(now)
            }
                
                (view as! BaseChartView).columnstep = -maxduration / 4
                (view as! BaseChartView).columninit = maxduration / 4 * 3
            
            
                var nextpointday = 1;
                
                
                let showcount :Int = months>12 ? 24:(Int(months)+1)*2
            
                if (history.count / showcount > 0){
                    nextpointday = history.count / showcount + 1
                }
                
           
                
                var dayfollowing = calender.startOfDay(for:  history[0].time! )
                
                 var min = history[0].capacity as! Int
                var max = history[0].capacity as! Int
                var numskip = 0
                var totalcap = 0
            
            for item in history {
                
                 let capacity = item.capacity as! Int
                
                if (capacity > max){
                    max = capacity
                }
                if (capacity < min){
                    min  = capacity
                }
                
               
                
                totalcap += capacity
           
                
                if ((dayfollowing.timeIntervalSince(calender.startOfDay(for:  item.time!))) > TimeInterval(0) ){
                    numskip += 1
                  
                    
                  
                    
                    continue;
                }
                
                dayfollowing = dayfollowing.addingTimeInterval(Double(nextpointday) * 86400.0 )

                
      
            let iteminterval = item.time?.timeIntervalSince(now)
                
       
                let xvalue  =  iteminterval! / interval!
                

                totalcap /= (numskip + 1)
                
                (view as! BaseChartView).linechart.append(CGPoint(x:1-xvalue,
                                          y: Double(totalcap ) / Double(iobattery.design_capacity)))
                

            

                
                
                
                
                
                
              //  print (String(format: "history: %d, %@", totalcap,showdate ))
                
                totalcap = 0
                numskip = 0
                
                    }
                
                if ((view as! BaseChartView).linechart.count>0){
                
                (view as! BaseChartView).linechart.append(CGPoint(x:1,
                                                                  y:  (view as! BaseChartView).linechart[(view as! BaseChartView).linechart.count-1].y))
                }
                

                
                (view as! BaseChartView).custommin = CGFloat(min)
                (view as! BaseChartView).custommax = CGFloat(max)
                
                
                if (history.count>30){
                 
                   let reg =  DetailViewController.calcatedline(history)
                   let date =  Date().timeIntervalSince1970
                    
                   let nowcap = DetailViewController.calcatepredict(x: date, slope: reg.slope, intersection: reg.intersect)
                    
                   let firstcap = DetailViewController.calcatepredict(x: (history[0].time?.timeIntervalSince1970)!, slope: reg.slope, intersection: reg.intersect)
                    
                        (view as! BaseChartView).reglineBegin = CGPoint(x:1-(history[0].time?.timeIntervalSinceNow)!/interval!,y:firstcap/Double(iobattery.design_capacity))
                    
                    (view as! BaseChartView).reglineEnd = CGPoint(x:1,y:nowcap/Double(iobattery.design_capacity))
                    
                    
                }
                
                
                
         
                
           
                }
            }catch {
                     //   fatalError("Failed to fetch history: \(error)")
            }
            
            
        
        
      
        
        view.layer?.setNeedsDisplay()
        view.layer?.displayIfNeeded()
        
        
    }
    
  
    
    
    
}

