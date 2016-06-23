//
//  User+CoreDataProperties.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/23/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var favorites: NSSet?

}
