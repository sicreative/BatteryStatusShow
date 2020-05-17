//
//  LogViewController.swift
//  BatteryStatusShow
//
//  Created by slee on 2017/5/30.
//  Copyright © 2017年 sicreativelee. All rights reserved.
//

import Cocoa

class LogViewController: BatteryViewController {
    @IBOutlet weak var resetButton: NSButton!
    @IBOutlet weak var exportButton: NSButton!
    @IBOutlet weak var stopButton: NSButton!
    @IBOutlet weak var startButton: NSButton!
    @IBOutlet weak var labelButton: NSButton!
    
    
    static let user_default_label_key = "default_log_label"
    
    static let magnifynotifykey =  AppDelegate.programprefix + ".logview_magnify_notify"
    static let movenotifykey =  AppDelegate.programprefix + ".logview_move_notify"
    
 

    var maxinterval:Int = Int.max
    var holdtomax = true
    
    var magnifystep = 0
    
    
    var offsettime:Int = 0
    var lastoffset:Int = 0
    
    var lasthistorycount = -1
    
    override func viewDidLoad() {
        
            super.viewDidLoad()
        
        resetButton.isEnabled = false
        exportButton.isEnabled = false
        stopButton.isEnabled = false
        startButton.isEnabled = true
        
      
        
            
            (view as! BaseChartView).title.stringValue = "Logging"
            (view as! BaseChartView).title.sizeToFit()
            
            (view as! BaseChartView).ytitle.stringValue = "capacity"
            (view as! BaseChartView).ytitle.sizeToFit()
            
            (view as! BaseChartView).xtitle.stringValue = ""
            (view as! BaseChartView).xtitle.sizeToFit()
            
            
            
            (view as! BaseChartView).showbelowcolor = true
            (view as! BaseChartView).showmaxmin = true
        
        (view as! BaseChartView).columnstep = 16 / 4
        (view as! BaseChartView).columninit = 16 / 4
        
       // (view as! BaseChartView).xtitle.stringValue = ""
        
        (view as! BaseChartView).chartaxiscolor = CGColor(red:0.3,green:0.8,blue:0.5,alpha:0.8)
        
       
        switchlabel(true)
        
        let dateformatter = DateFormatter()
        dateformatter.timeZone = NSTimeZone.local
        dateformatter.dateStyle = .none
        dateformatter.timeStyle = .short
        
        for i in 0...3{
            let interval = 60.0*16.0
            (view as! BaseChartView).columnlabel[i].font = NSFont(name:"Helvetica Neue Medium", size:10)
            (view as! BaseChartView).columnlabel[i].stringValue = dateformatter.string(from: Date().addingTimeInterval(-interval+interval/4*Double(i+1)))
            (view as! BaseChartView).columnlabel[i].sizeToFit()
        }
        
        switchlabel( UserDefaults.standard.bool(forKey: LogViewController.user_default_label_key))
        
  

         NotificationCenter.default.addObserver(self, selector:#selector(self.magnify(notification:)), name: NSNotification.Name(rawValue:LogViewController.magnifynotifykey), object: nil)
        
              NotificationCenter.default.addObserver(self, selector:#selector(self.move(notification:)), name: NSNotification.Name(rawValue:LogViewController.movenotifykey), object: nil)
            
      
    }
    
    @IBAction func LabelButtonAction(_ sender: Any) {
        switchlabel()
     
        UserDefaults.standard.set((view as! StatusBaseChartView).showlabel,  forKey: LogViewController.user_default_label_key)
    }
  
    
    @IBAction func ResetButtonAction(_ sender: Any) {
        
        let logFetch :NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Log")
        
        logFetch.predicate = NSPredicate(format:"( serialno = %@ )",iobattery.battery_serialno)
        
        let delrequest =  NSBatchDeleteRequest(fetchRequest: logFetch)
       
        iobattery.save = true
        iobattery.databasesave()

        

        
        
        
        do {
            
            
           
         
        try datacontroller.managedObjectContext.execute(delrequest)
        
            
            
             //    result?.result as?  [NSManagedObjectID]
           // let changes :[String:Any] = [NSDeletedObjectsKey : objectarray]
            
         //   NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [datacontroller.managedObjectContext])
           
           // try datacontroller.managedObjectContext.save()

            
        } catch {
            fatalError("Failed to execute request: \(error)")
        }
        
        
    
        
          
      
            

       
        
     
        
     
   
        
       
        
     
   
        
        if (iobattery==nil){
            updatebatteryinfo()
          
            
        }
        
        
     
        
        (view as! StatusBaseChartView).labeltext.removeAll()
        
        
        
        
        updateview()
        
        
        
        
    }
    
    
    
    
    @IBAction func ExportButtonAction(_ sender: Any) {
        if (iobattery==nil){
            update()
            
        }
        
        let savepanel = NSSavePanel()
        savepanel.message = "Export to CSV"
        savepanel.title = "Export"
        savepanel.allowedFileTypes = ["csv"]
        savepanel.canCreateDirectories = true
        savepanel.allowsOtherFileTypes = true
        savepanel.begin(completionHandler: { clickbutton in
            if (clickbutton.rawValue==NSFileHandlingPanelOKButton){
              
                self.processexport(savepanel.url!)
            }
            
        })
        
    }
    
    
 
    
    
    @IBAction func StopButtonAction(_ sender: Any) {
        if (iobattery==nil){
            update()
            }
        NotificationCenter.default.post(name:Notification.Name(IOBattery.lognotify), object: nil, userInfo: ["trigger":"stop"])
       
     
        update()
        
    }
    
    @IBAction func StartButtonAction(_ sender: Any) {
        if (iobattery==nil){
            update()
        }

        
        NotificationCenter.default.post(name:Notification.Name(IOBattery.lognotify), object: nil, userInfo: ["trigger":"start","serialno":iobattery.battery_serialno])
        
        holdtomax = true;
        offsettime = 0;
        
        update()
        
       
        
    }
    
    
    override func updateview() {
        
        if (iobattery.logging){
            
            startButton.isEnabled = false
            stopButton.isEnabled = true
            
            resetButton.isEnabled =  false
            exportButton.isEnabled = false
            
        }else{
            
            startButton.isEnabled = true
            stopButton.isEnabled = false
            
            resetButton.isEnabled = true
            exportButton.isEnabled = true
        }
        
        (view as! BaseChartView).linechart.removeAll()
         (view as! StatusBaseChartView).linechartstatus.removeAll()
 
        
        if (datacontroller==nil){
        return;
        }
        
        
        
        
        
        let logFetch :NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Log")
        logFetch.sortDescriptors = [NSSortDescriptor(key: "time", ascending: true)]
        
        logFetch.predicate = NSPredicate(format:"( serialno = %@ )",iobattery.battery_serialno)
        
  
        
       
     
        
        do {
         var   history = try datacontroller.managedObjectContext.fetch(logFetch) as! [LogMO]
            
        
            
            
            
            let dateformatter = DateFormatter()
            dateformatter.timeZone = NSTimeZone.local
            dateformatter.dateStyle = .none
            dateformatter.timeStyle = .short
            
            if (history.count>0){
                
                /*
                
                if (history.count == lasthistorycount){
                    return
                }
                
                lasthistorycount = history.count
                */
                
             
                
                var interval = Int((history[history.count-1].time?.timeIntervalSince(history[0].time! as Date))!)
                let mins = interval / 60
                let hour = mins / 60
                let day = hour / 24
                
               
           
                if (mins<16){
                      //  (view as! BaseChartView).columnstep = 16 / 4
                      //  (view as! BaseChartView).columninit = 16 / 4
                        interval = 16*60
                    
                    
                } else if (mins<32){
                   // (view as! BaseChartView).columnstep = 32 / 4
                   // (view as! BaseChartView).columninit = 32 / 4
                    interval = 32*60
                   
                }else if (mins<60){
               // (view as! BaseChartView).columnstep = 60 / 4
               // (view as! BaseChartView).columninit = 60 / 4
                    interval = 60*60
               
                }else if (hour < 24){
                  //  (view as! BaseChartView).columnstep = hour / 4 + 1
                 //   (view as! BaseChartView).columninit = (hour / 4 + 1)
                    interval = 60*60*(hour / 4 + 1)*4
                    
                }else  {
                  //  (view as! BaseChartView).columnstep = day / 4 + 1
                 //   (view as! BaseChartView).columninit = (day / 4 + 1)
                    interval = 60*60*24*(day / 4 + 1) * 4
               
                    
                }
                
                
                
                if (interval > maxinterval){
                   // if (!holdtomax){
                        interval = maxinterval
                  // }
                }else if (interval < maxinterval){
                    holdtomax = true
                   
                    maxinterval = interval
                    
                }
                
                magnifystep = Int(interval / 5000)
                
                if (magnifystep < 2){
                    magnifystep = 2
                }
                
                   let nextpointsecond :Int = interval / 120
                
            
                
                if (interval > 60*60*24){
                    
                    dateformatter.dateStyle = .short
                    dateformatter.timeStyle = .none
                }
         
              
                var endtime = (history[history.count-1].time! as Date)+Double(offsettime)
        
                
                
               
                var starttime =  endtime.addingTimeInterval(-Double(interval))
                
                
         
                
                
                if ( starttime < history[0].time! as Date ){
                    
                    if (offsettime<lastoffset){
                        offsettime = lastoffset
                    }
                    
                  //  if (Int((endtime.timeIntervalSince(history[0].time! as Date))) < interval){
                  //      offsettime = 0
                  //  }
                    
                    endtime = (history[history.count-1].time! as Date)+Double(offsettime)
                    
                    starttime =  endtime.addingTimeInterval(-Double(interval))
                  
                    
                  
                  //  offsettime = Int(history[history.count-1].time!.timeIntervalSince((history[0].time! as Date).addingTimeInterval(-TimeInterval(interval)) ))
                }
                
            //    print (String(format:"offset:%d,last:%d",offsettime,lastoffset))
                
              // let endtime =  (history[history.count-1].time! as Date).addingTimeInterval(-Double(offsettime))
               
                
         
         
                
                
                dateformatter.dateStyle = .short
                dateformatter.timeStyle = .short
               
                for i in 0...3{
                    
            
                    
                    let time =  starttime.addingTimeInterval(Double(interval)/4*Double(i+1))
                    
                    let cal = Calendar(identifier: .gregorian)
                    if (i>0){
                        if (cal.isDate(time, inSameDayAs: starttime.addingTimeInterval(Double(interval)/4*Double(i)))){
                            dateformatter.dateStyle = .none
                            dateformatter.timeStyle = .short
                        }else{
                            if (dateformatter.dateStyle == .none){
                                dateformatter.dateStyle = .short
                                dateformatter.timeStyle = .short
                            }else{
                                dateformatter.dateStyle = .short
                                dateformatter.timeStyle = .none
                            }
                        }
                        
                    }
                 
                (view as! BaseChartView).columnlabel[i].stringValue = dateformatter.string(from: time)
                   
                    (view as! BaseChartView).columnlabel[i].sizeToFit()
                    
                  
                }
                
              

                dateformatter.dateStyle = .medium
                dateformatter.timeStyle = .medium
                
                    let firstshowdate = dateformatter.string(from: history[0].time! as Date)
                
                
                if (history.count > 2){
                 var trimmedhistory = [LogMO]()
                    for (i,item) in history.enumerated() {
                       
                        
                        let time = item.time! as Date
                     //   let follwardtime = history[i+1].time! as Date
                        
                        if (time <= starttime && i < history.count-2 && history[i+1].time! as Date > starttime){
                            trimmedhistory.append(item)
                        }else if (time >= starttime && time < endtime){
                            trimmedhistory.append(item)
                        }else if (time >= endtime){
                            trimmedhistory.append(item)
                            break
                        }
                    
                    
                    }
                    
                    
                    history = trimmedhistory
                    
                

                
                
             
                
                
                
                
            
                
              
                
                
                var dayfollowing = history[0].time
                
                var max:Int = Int((history.max(by: { a,b in
                    a.capacity < b.capacity})?.capacity)!)
                    
                let min = Int((history.min(by: { a,b in
                    a.capacity < b.capacity})?.capacity)!)
               
                
            
                
               
                
                (view as! BaseChartView).custommin = CGFloat(min)
                (view as! BaseChartView).custommax = CGFloat(max)
                
                if (iobattery.max_capacity  > max){
                    max = iobattery.max_capacity
                }
             
                
                (view as! BaseChartView).rowstep = max / 4
                (view as! BaseChartView).rowinit = max / 4
                
              
               
                var addlabelposx = CGFloat(-1)
                
                (view as! StatusBaseChartView).labeltext.removeAll()
                    
                  var lastcap = history[0].capacity
                
                for (i,item) in history.enumerated() {
                    
                   
                    
            
                    
                    
                    
              
                    var addlabel = false
                    
                   if (i > 0 && i < history.count-1 && item.charging == history[i-1].charging && item.usebattery == history[i-1].usebattery ){
                  
                      //  if (i < history.count-1 && item.charging == history[i+1].charging && item.usebattery == history[i+1].usebattery && i > 0){
                            
                             if (dayfollowing! as Date > item.time! as Date   ){
                                    continue;
                            }
                        }else{
                            addlabel = true
                        }
                        
                        
                        
                        
                   
                    
                     let capacity = item.capacity
                    
                   dayfollowing = dayfollowing?.addingTimeInterval(TimeInterval(nextpointsecond))
                    
                    
                    
                    let showdate = dateformatter.string(from: item.time! as Date)
                    let iteminterval = Int((endtime).timeIntervalSince(item.time! as Date))
                    
                    
                  
                        let xvalue  = interval<=0 ? 0 : Double(iteminterval) / Double(interval)
                   
                    var pos = CGPoint(x:1-xvalue,y: Double(capacity ) / Double(max))
        
                    
                    (view as! BaseChartView).linechart.append(pos)
                    
                    var linestatus = item.usebattery ? 1 : item.charging ? 2 : 0
                  // let linestatus = Int(arc4random_uniform(3))
                    
                    
                    
                    if (i>0 && linestatus == 0 ){
                        let devriation = lastcap - item.capacity
                        
                        if (devriation > 300){
                           linestatus = 1
                            addlabel = true
                        }else if (devriation < -300){
                            linestatus = 2
                            addlabel = true
                        }
                        
                        
                    }
                    
                    (view as! StatusBaseChartView).linechartstatus.append(linestatus)

                    
                    
                    
                    
                    if (addlabel){
                        
                        if (addlabelposx <= -1 || pos.x-addlabelposx>0.03){
                            
                            if (pos.x<0){
                                pos.x = -0.0075
                                (view as! StatusBaseChartView).labeltext[firstshowdate] = pos

                            }else {
                                if (pos.x > 1){
                                    pos.x = 1
                                }
                                (view as! StatusBaseChartView).labeltext[showdate] = pos
                              }
                            
                            
                            addlabelposx = pos.x

                            
                        }
                        
                    
                        
                        
                    }
                    
                    
                    lastcap = item.capacity
                    
                    
                //    print (String(format: "log: %d, %@", capacity,showdate ))
                    
                   
                    
                }
                
                if ((view as! BaseChartView).linechart.count==1){
                    
                    (view as! BaseChartView).linechart.append(CGPoint(x:0.99,
                                                                      y:  (view as! BaseChartView).linechart[0].y))
                    (view as! StatusBaseChartView).linechartstatus.append ((view as! StatusBaseChartView).linechartstatus[0])
                }
                
                
                
                
                
                
                if ((view as! BaseChartView).linechart.count >= 2){
                   // (view as! BaseChartView).linechart[count-1].x = 1;
                    
                    
                    
                    
                    
                    //Alighment of left edge
                    
                    
                    
                    if ((view as! BaseChartView).linechart[0].x<0){
                        
                        let a = (view as! BaseChartView).linechart[0]
                        let b = (view as! BaseChartView).linechart[1]
                        let slope = (a.y - b.y) / (a.x - b.x)
                        
                        // y = mx + b
                        (view as! BaseChartView).linechart[0].y = b.y - slope * b.x
                        
                        
                        
                        (view as! BaseChartView).linechart[0].x = 0
                        
                        
                    }
                    
                    
                    if ((view as! BaseChartView).linechart[(view as! BaseChartView).linechart.count-1].x>1){
                        
                        let a = (view as! BaseChartView).linechart[(view as! BaseChartView).linechart.count-2]
                        let b = (view as! BaseChartView).linechart[(view as! BaseChartView).linechart.count-1]
                        let slope = (a.y - b.y) / (a.x - b.x)
                        
                        
                        (view as! BaseChartView).linechart[(view as! BaseChartView).linechart.count-1].y = a.y + slope * (1-a.x)
                        
                        
                        
                        (view as! BaseChartView).linechart[(view as! BaseChartView).linechart.count-1].x = 1
                        
                        
                    }
                    
                }
                
                
                
                
                resetButton.isEnabled = iobattery.logging ? false : true
                 exportButton.isEnabled = iobattery.logging ? false : true
                
            
                
            }else{
                
                resetButton.isEnabled = false
                exportButton.isEnabled = false
               
            }
        }
            
            
        }catch {
            return
           // fatalError("Failed to fetch history: \(error)")
        }
        
        lastoffset = offsettime
        
        view.layer?.setNeedsDisplay()
        view.layer?.displayIfNeeded()
        
        
        

        
        
    }
    
    
    func switchlabel(){
        
            self.switchlabel(!(view as! StatusBaseChartView).showlabel)
        
    }
    
    func switchlabel(_ onoff:Bool)  {
        if (onoff){
            (view as! StatusBaseChartView).showlabel = true
           
                labelButton.state = .on
            
        }else{
            (view as! StatusBaseChartView).showlabel = false
               labelButton.state = .off
            
        }
        
        
        
        view.layer?.setNeedsDisplay()
        view.layer?.displayIfNeeded()
    }
    
    
    func processexport(_ url:URL){
        let logFetch :NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Log")
        logFetch.sortDescriptors = [NSSortDescriptor(key: "time", ascending: true)]
        
        logFetch.predicate = NSPredicate(format:"( serialno = %@ )",iobattery.battery_serialno)
        
        let dateformatter = DateFormatter()
        dateformatter.timeZone = NSTimeZone.local
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        
        var exportstring = "Time,Capacity,Max Capacity,Design"
        exportstring.append("Capacity,Cycle,Voltage,Current,Charging,Usebattery,Temperature,Serialno\n")

        
        do {
            let history = try datacontroller.managedObjectContext.fetch(logFetch) as! [LogMO]
            
            
            
            for item in history {
              
                
                
                exportstring.append(dateformatter.string(from: item.time! as Date) + ",")
                exportstring.append(item.capacity.description + ",")
                exportstring.append(item.maxcapacity.description + ",")
                exportstring.append(item.designcapacity.description + ",")
                exportstring.append(item.cycle.description + ",")
                exportstring.append(item.voltage.description + ",")
                exportstring.append(item.current.description + ",")
                exportstring.append((item.charging ? "1":"0") + ",")
                exportstring.append((item.usebattery ? "1":"0") + ",")
                exportstring.append(item.temperature.description + ",")
                exportstring.append(item.serialno! + "\n")
                
            }
            
            
            
            
        }catch {
            fatalError("Failed to fetch history: \(error)")
        }
        
        
        do {try exportstring.write(to: url, atomically: false, encoding: String.Encoding.utf8)
        }catch{
            fatalError("Write error: \(error)")

        }
       
        
    }
    
    
    @objc func magnify(notification:Notification){
      //  print (String(format:"recevied %f",notification.userInfo?["magnification"] as! CGFloat))
        maxinterval += (Int(notification.userInfo?["magnification"] as! CGFloat ) * magnifystep )
        holdtomax = false
        
        
        
        if (maxinterval < 16*60){
            maxinterval = 16*60
        }
        
        
        update()
    }
    
    @objc func move(notification:Notification){
        
      
            
        
      //  print (String(format:"recevied move %f",notification.userInfo?["moving"] as! CGFloat))
        
     //  self.lastoffset = self.offsettime
        
        self.offsettime += Int(notification.userInfo?["moving"] as! CGFloat) * magnifystep
        
        if (self.offsettime > 0){
            self.offsettime = 0
        }
        

        
        
        self.update()
        
    }







}
