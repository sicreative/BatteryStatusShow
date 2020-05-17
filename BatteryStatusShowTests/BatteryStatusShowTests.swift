//
//  BatteryStatusShowTests.swift
//  BatteryStatusShowTests
//
//  Created by slee on 2017/5/10.
//  Copyright © 2017年 sicreativelee. All rights reserved.
//

import XCTest
@testable import BatteryStatusShow

class BatteryStatusShowTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceDatabase() {
        
        let iobattery = (NSApplication.shared.delegate as! AppDelegate).getBattery()
        
        let testbattery_serialno = "TEST"
        // This is an example of a performance test case.
        self.measure {

          
            //Run Loop for insert
            for _ in 1...10000{
            
            iobattery.rundatabase ("History", iobattery.max_capacity as NSNumber, Date(timeIntervalSince1970: iobattery.lastupdatetime as! TimeInterval), iobattery.cycle_count as NSNumber, iobattery.tempKtoC() as NSNumber, testbattery_serialno as NSString)
                
                iobattery.save = true;
            
            iobattery.databasesave()
            }
            
      
            }
            
            
            let historyFetch :NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "History")
            historyFetch.sortDescriptors = [NSSortDescriptor(key: "time", ascending: true)]
            
            historyFetch.predicate = NSPredicate(format:"( serialno = %@ )",testbattery_serialno)
            
        
            
            //Remove all test inserts
            do {
             
                
                let batchdelete = NSBatchDeleteRequest(fetchRequest: historyFetch);
                
                try iobattery.datacontroller.managedObjectContext.execute(batchdelete);
                
                iobattery.databasesave()
            }catch {
                
            }


            
            // Put the code you want to measure the time of here.
        
    }
    
}
