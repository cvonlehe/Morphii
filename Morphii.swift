//
//  Morphii.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/10/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import Foundation
import CoreData


class Morphii: NSManagedObject {
    
    static let EntityName = "Morphii"

// Insert code here to add functionality to your managed object subclass
//    init(id: String, name: String, scaleType: Int, /*category: String, keywords: [ String ],*/ sequence: Int, metaData: NSDictionary) {
//        super.init()
//        setData(id, name: name, scaleType: scaleType, sequence: sequence, metaData: metaData)
//    }
    
    
//    
    class func createNewMorphii (morphiiRecord:NSDictionary) -> Morphii? {
        
        let data = morphiiRecord.valueForKey(MorphiiAPIKeys.data) as! NSDictionary
        let metaData = data.valueForKey(MorphiiAPIKeys.metaData) as! NSDictionary
        let scaleType = morphiiRecord.valueForKey(MorphiiAPIKeys.scaleType) as! Int
        let recId = morphiiRecord.valueForKey(MorphiiAPIKeys.id) as! String
        let recName = morphiiRecord.valueForKey(MorphiiAPIKeys.name) as! String
        //let recCategory = morphiiRecords[i].valueForKey("category") as! String
        //let recKeywords = morphiiRecords[i].valueForKey("keywords") as! [ String ]
        let recSequence = morphiiRecord.valueForKey(MorphiiAPIKeys.sequence) as! Int
        let groupName = morphiiRecord.valueForKey(MorphiiAPIKeys.groupName) as! String
        return setData(recId, name: recName, scaleType: scaleType, sequence: recSequence, groupName:groupName, metaData: metaData)
    }
    
    private class func setData(id: String, name: String, scaleType: Int, /*category: String, keywords: [ String ],*/ sequence: Int, groupName:String, metaData: NSDictionary) -> Morphii? {
        guard let morphii = NSEntityDescription.insertNewObjectForEntityForName(EntityNames.Morphii, inManagedObjectContext: CDHelper.sharedInstance.managedObjectContext) as? Morphii else {
            return nil
        }
        morphii.id = id
        morphii.name = name
        morphii.scaleType = scaleType
        //self.category = category
        //self.keywords = keywords
        morphii.groupName = groupName
        morphii.sequence = sequence
        morphii.metaData =  metaData
        
        do {
            try CDHelper.sharedInstance.managedObjectContext.save()
            return morphii
        }catch {
            return nil
        }
        
    }
    
    class func fetchAllMorphiis () -> [Morphii] {
        var morphiis:[Morphii] = []
        let request = NSFetchRequest(entityName: EntityNames.Morphii)
        do {
            guard let m = try CDHelper.sharedInstance.managedObjectContext.executeFetchRequest(request) as? [Morphii] else {
                return []
            }
            morphiis.appendContentsOf(m)
        }catch {
            return []
        }
        return morphiis
    }
}
