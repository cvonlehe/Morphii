//
//  CDHelper.swift
//  CoreDataStack
//
//  Created by Charlie  on 6/1/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import Foundation
import CoreData

class CDHelper {
    static let sharedInstance = CDHelper()
    
    lazy var storageDirectory:NSURL = {
        let fm = NSFileManager.defaultManager()
        let url = fm.containerURLForSecurityApplicationGroupIdentifier("group.morphiiapp")
        return url!
    }()
    
    lazy var localStoreURL:NSURL = {
        let url = self.storageDirectory.URLByAppendingPathComponent("MorphiiCoreDataStack.sqlite")
        return url
    }()
    
    lazy var modelURL:NSURL = {
        let bundle = NSBundle.mainBundle()
        if let url = bundle.URLForResource("Model", withExtension: "momd") {
            return url
        }
        print("CRITICAL - FAILURE")
        abort()
    }()
    
    lazy var model:NSManagedObjectModel = {
        return NSManagedObjectModel(contentsOfURL: self.modelURL)!
    }()
    
    lazy var coordinator:NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.model)
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: self.localStoreURL, options: nil)
        }catch {
            print("Could not add the persistent store")
            abort()
        }
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.coordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    func saveContext (completion:((success:Bool)->Void)?) {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                if let comp = completion {
                    comp(success: false)
                    return
                }
            }
        }
        if let comp = completion {
            comp(success: true)
        }
    }
}