//
//  User.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/23/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import Foundation
import CoreData


class User: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    class func getCurrentUser () -> User? {
        let request = NSFetchRequest(entityName: EntityNames.User)
        do {
            if let users = try CDHelper.sharedInstance.managedObjectContext.executeFetchRequest(request) as? [User],
            let user = users.first {
                return user
            }
        }catch {
            return nil
        }
        guard let user = NSEntityDescription.insertNewObjectForEntityForName(EntityNames.User, inManagedObjectContext: CDHelper.sharedInstance.managedObjectContext) as? User else {return nil}
        do {
            try CDHelper.sharedInstance.managedObjectContext.save()
            return user
        }catch {
            return nil
        }
    }

}
