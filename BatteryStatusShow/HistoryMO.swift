//
//  HistoryMO.swift
//  BatteryStatusShow
//
//  Created by slee on 2017/5/17.
//  Copyright © 2017年 sicreativelee. All rights reserved.
//

import Cocoa



class HistoryMO: NSManagedObject {
     @NSManaged var capacity: NSNumber?
     @NSManaged var cycle: NSNumber?
    @NSManaged var time: Date?
    @NSManaged var temperature: NSNumber?
    @NSManaged var serialno: NSString?
   
    
    
}
