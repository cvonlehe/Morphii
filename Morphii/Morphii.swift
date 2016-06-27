//
//  Morphii.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/23/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import Foundation
import CoreData


class Morphii: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    static let EntityName = "Morphii"
    
    // Insert code here to add functionality to your managed object subclass
    //    init(id: String, name: String, scaleType: Int, /*category: String, keywords: [ String ],*/ sequence: Int, metaData: NSDictionary) {
    //        super.init()
    //        setData(id, name: name, scaleType: scaleType, sequence: sequence, metaData: metaData)
    //    }
    
    
    //
    class func createNewMorphii (morphiiRecord:NSDictionary, emoodl:Double?, isFavorite:Bool) -> Morphii? {
        
        let data = morphiiRecord.valueForKey(MorphiiAPIKeys.data) as! NSDictionary
        let metaData = data.valueForKey(MorphiiAPIKeys.metaData) as! NSDictionary
        let scaleType = morphiiRecord.valueForKey(MorphiiAPIKeys.scaleType) as! Int
        let recId = morphiiRecord.valueForKey(MorphiiAPIKeys.id) as! String
        let recName = morphiiRecord.valueForKey(MorphiiAPIKeys.name) as! String
        //let recCategory = morphiiRecords[i].valueForKey("category") as! String
        var keywords:[String] = []
        if let keys = morphiiRecord.valueForKey(MorphiiAPIKeys.keywords) as? [String] {
            keywords = keys
        }
        //let recKeywords = morphiiRecords[i].valueForKey("keywords") as! [ String ]
        let recSequence = morphiiRecord.valueForKey(MorphiiAPIKeys.sequence) as! Int
        let groupName = morphiiRecord.valueForKey(MorphiiAPIKeys.groupName) as! String
        return setData(recId, name: recName, scaleType: scaleType, sequence: recSequence, groupName:groupName, metaData: metaData, emoodl: emoodl, isFavorite: isFavorite, tags: keywords)
    }
    
    class func createNewMorphii(id: String?, name: String?, scaleType: Int?, /*category: String, keywords: [ String ],*/ sequence: Int?, groupName:String?, metaData: NSDictionary?, emoodl:Double?, isFavorite:Bool, tags:[String]) -> Morphii? {
        guard let i = id, let n = name, let scale = scaleType, let seq = sequence, let group = groupName, let data = metaData, let em = emoodl else {return nil}
        return setData(i, name: n, scaleType: scale, sequence: seq, groupName: group, metaData: data, emoodl: em, isFavorite: isFavorite, tags: tags)
    }
    
    private class func setData(id: String, name: String, scaleType: Int, /*category: String, keywords: [ String ],*/ sequence: Int, groupName:String, metaData: NSDictionary, emoodl:Double?, isFavorite:Bool, tags:[String]) -> Morphii? {
        
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
        morphii.isFavorite = isFavorite
        morphii.emoodl = 50.0
        morphii.tags = NSMutableArray(array: tags)
        if let newEmoodl = emoodl {
            morphii.emoodl = newEmoodl
        }
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
    
    class func getCollectionTitles () -> [String] {
        var collections:[String] = []
        for morphii in fetchAllMorphiis() {
            guard let collection = morphii.groupName else {continue}
            if !collections.contains(collection) {
                collections.append(collection)
            }
        }
        return collections.sort()
    }
    
    class func getMorphiisForCollectionTitle (collectionTitle:String) -> [Morphii] {
        var morphiis:[Morphii] = []
        let request = NSFetchRequest(entityName: EntityNames.Morphii)
        let predicate = NSPredicate(format: "groupName == %@", collectionTitle)
        request.predicate = predicate
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
    
    class func getTagsFromString (string:String?) -> [String] {
        guard let _ = string else {return []}
        let newString = string!.stringByReplacingOccurrencesOfString("#", withString: "")
        var components = newString.componentsSeparatedByString(" ")
        for component in components {
            if component == "", let index = components.indexOf(component) {
                components.removeAtIndex(index)
            }
        }
        return components
    }
}
