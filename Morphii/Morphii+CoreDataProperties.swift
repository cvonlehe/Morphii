//
//  Morphii+CoreDataProperties.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/14/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Morphii {

    @NSManaged var id: String?
    @NSManaged var metaData: NSDictionary?
    @NSManaged var name: String?
    @NSManaged var scaleType: NSNumber?
    @NSManaged var sequence: NSNumber?
    @NSManaged var groupName: String?

}
