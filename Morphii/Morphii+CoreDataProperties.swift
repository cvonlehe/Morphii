//
//  Morphii+CoreDataProperties.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/30/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Morphii {

    @NSManaged var emoodl: NSNumber?
    @NSManaged var groupName: String?
    @NSManaged var id: String?
    @NSManaged var isFavorite: NSNumber?
    @NSManaged var metaData: NSDictionary?
    @NSManaged var name: String?
    @NSManaged var scaleType: NSNumber?
    @NSManaged var sequence: NSNumber?
    @NSManaged var tags: NSMutableArray?
    @NSManaged var order: NSNumber?

}
