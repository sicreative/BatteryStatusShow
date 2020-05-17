//
//  CycleEntityMigrationPolicy.swift
//  BatteryStatusShow
//
//  Created by slee on 2017/5/22.
//  Copyright © 2017年 sicreativelee. All rights reserved.
//

import Cocoa



class CycleEntityMigrationPolicy : NSEntityMigrationPolicy {
    
     // public let NSMigrationEntityPolicyKey = "CycleEntityMigrationPolicy"
  
    
   
    
    
    override func createRelationships(forDestination dInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {

       try super.createRelationships(forDestination:  dInstance,in: mapping,manager:  manager)
        
       let count = (NSApplication.shared.delegate as! AppDelegate).getBattery().cycle_count
       let temp = (NSApplication.shared.delegate as! AppDelegate).getBattery().tempKtoC()
       dInstance.setValue(count, forKey: "cycle")
        dInstance.setValue(temp, forKey: "temperature")
        
        
        
        
        
        // let destinattion = dInstance as! HistoryMO
       // destinattion.cycle = 0
    }
}


