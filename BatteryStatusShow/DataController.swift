//
//  DataController.swift
//  BatteryStatusShow
//
//  Created by slee on 2017/5/17.
//  Copyright © 2017年 sicreativelee. All rights reserved.
//

import Cocoa


class DataController : NSObject {

    
     var managedObjectContext: NSManagedObjectContext
    
    
    init(completionClosure: @escaping () -> ()) {
    //This resource is the same name as your xcdatamodeld contained in your project
        guard let modelURL = Bundle.main.url(forResource: "data", withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
    
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
    
        managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = psc
    
        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
            queue.async {
                    guard var docURL = FileManager.default.urls(for: .applicationSupportDirectory , in: .userDomainMask).last else {
            fatalError("Unable to resolve document directory")
                }
                
            docURL.appendPathComponent((Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String)!)
              
                let isDir = UnsafeMutablePointer<ObjCBool>.allocate(capacity: 1)
                isDir.initialize(to: ObjCBool(true))
                
                if (!FileManager.default.fileExists(atPath: docURL.path, isDirectory: isDir)){
                
                do {
                
                    try FileManager.default.createDirectory(at:docURL, withIntermediateDirectories: false, attributes: nil)
                } catch let error as NSError {
                    print(error.localizedDescription);
                }
                }
                
                isDir.deinitialize(count: 0)
                
        let storeURL = docURL.appendingPathComponent("data.sqlite")
        do {
            try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: [NSMigratePersistentStoresAutomaticallyOption:true])
            //The callback block is expected to complete the User Interface and therefore should be presented back on the main queue so that the user interface does not need to be concerned with which queue this call is coming from.
                DispatchQueue.main.sync(execute: completionClosure)
        } catch {
            
          //  fatalError("Error migrating store: \(error)")
        }
    }
}
}
