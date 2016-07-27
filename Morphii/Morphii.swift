//
//  Morphii.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/23/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import Foundation
import CoreData
import UIKit

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
    
        if let morphii = getMorphiisForId(recId) {
            morphii.deleteMorphii(nil)
        }
        
        return setData(recId, name: recName, scaleType: scaleType, sequence: recSequence, groupName:groupName, metaData: metaData, emoodl: emoodl, isFavorite: isFavorite, tags: keywords, order: 1, originalId: nil, originalName: nil)
    }
    
    class func createNewMorphii(id: String?, name: String?, scaleType: Int?, /*category: String, keywords: [ String ],*/ sequence: Int?, groupName:String?, metaData: NSDictionary?, emoodl:Double?, isFavorite:Bool, tags:[String], order:Int, originalId:String?, originalName:String?) -> Morphii? {
        
        guard let i = id, let n = name, let scale = scaleType, let seq = sequence, let group = groupName, let data = metaData, let em = emoodl else {return nil}
        return setData(i, name: n, scaleType: scale, sequence: seq, groupName: group, metaData: data, emoodl: em, isFavorite: isFavorite, tags: tags, order: order, originalId: originalId, originalName: originalName)
    }
    
    private class func setData(id: String, name: String, scaleType: Int, /*category: String, keywords: [ String ],*/ sequence: Int, groupName:String, metaData: NSDictionary, emoodl:Double?, isFavorite:Bool, tags:[String], order:Int, originalId:String?, originalName:String?) -> Morphii? {
        
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
        morphii.originalId = originalId
        morphii.originalName = originalName
        if let newEmoodl = emoodl {
            morphii.emoodl = newEmoodl
        }
        do {
            try CDHelper.sharedInstance.managedObjectContext.save()
            if isFavorite {
                morphii.setLastUsedDate(NSDate())
            }
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
    
    class func getMorphiisForIds (ids:[String]) -> [Morphii] {
        var morphiis:[Morphii] = []
        let request = NSFetchRequest(entityName: EntityNames.Morphii)
        let predicate = NSPredicate(format: "id IN %@", ids)
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
    
    class func getMorphiisForId (id:String) -> Morphii? {
        let request = NSFetchRequest(entityName: EntityNames.Morphii)
        let predicate = NSPredicate(format: "id == %@", id)
        request.predicate = predicate
        do {
            guard let m = try CDHelper.sharedInstance.managedObjectContext.executeFetchRequest(request) as? [Morphii] else {
                return nil
            }
            return m.first
        }catch {
            return nil
        }
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
    
    class func getMorphiisForSearchString (searchString:String?) -> [Morphii] {
        var morphiis:[Morphii] = []
        guard var string = searchString?.stringByReplacingOccurrencesOfString(" ", withString: "") else {return morphiis}
        if string == "" {
            return morphiis
        }
        let request = NSFetchRequest(entityName: Morphii.EntityName)
        let predicate = NSPredicate(format: "(name contains [cd] %@)", string)
        request.predicate = predicate
        let sort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sort]
        do {
            guard let m = try CDHelper.sharedInstance.managedObjectContext.executeFetchRequest(request) as? [Morphii] else {return []}
            morphiis.appendContentsOf(m)
        }catch {
            return []
        }
        return morphiis
    }
    
    class func getTagsForSearchString (searchString:String?) -> [String] {
        var tags:[String] = []
        guard let string = searchString?.stringByReplacingOccurrencesOfString(" ", withString: "") else {return []}
        if string == "" {
            return []
        }
        let request = NSFetchRequest(entityName: Morphii.EntityName)
        let sort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sort]
        do {
            guard let morphiis =  try CDHelper.sharedInstance.managedObjectContext.executeFetchRequest(request) as? [Morphii] else {return []}
            for morphii in morphiis {
                if let tagArray = morphii.tags {
                    let array = NSArray(array: tagArray)
                    if let ts = array as? [String] {
                        for tag in ts {
                            if tag.lowercaseString.containsString(string.lowercaseString) && !tags.contains(tag.lowercaseString) {
                                tags.append(tag.lowercaseString)
                            }
                        }
                    }
                }
            }
        }catch {
            return []
        }
        return tags
    }
    
    class func getCollectionsForSearchString (searchString:String?) -> [Morphii] {
        var morphiis:[Morphii] = []
        var groupNames:[String] = []
        guard let string = searchString?.stringByReplacingOccurrencesOfString(" ", withString: "") else {return []}
        if string == "" {
            return []
        }
        let request = NSFetchRequest(entityName: Morphii.EntityName)
        let predicate = NSPredicate(format: "(groupName contains [cd] %@)", string)
        request.predicate = predicate
        let sort = NSSortDescriptor(key: "groupName", ascending: true)
        request.sortDescriptors = [sort]
        do {
            guard let m = try CDHelper.sharedInstance.managedObjectContext.executeFetchRequest(request) as? [Morphii] else {return []}
            for morphii in m {
                if let groupName = morphii.groupName {
                    if !groupNames.contains(groupName) {
                        morphiis.append(morphii)
                        groupNames.append(groupName)
                    }
                }
            }
        }catch {
            return []
        }
        return morphiis
    }
    
    class func getMorphiisForTagContainingString (searchString:String?) -> [Morphii] {
        var morphiis:[Morphii] = []
        guard var string = searchString?.stringByReplacingOccurrencesOfString(" ", withString: "") else {return morphiis}
        if string == "" {
            return morphiis
        }
        string = string.stringByReplacingOccurrencesOfString("#", withString: "")
        let request = NSFetchRequest(entityName: Morphii.EntityName)
        let sort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sort]
        do {
            guard let m = try CDHelper.sharedInstance.managedObjectContext.executeFetchRequest(request) as? [Morphii] else {return []}
            for morphii in m {
                if let tagArray = morphii.tags {
                    let array = NSArray(array: tagArray)
                    if let ts = array as? [String] {
                        for tag in ts {
                            if tag.lowercaseString.containsString(string.lowercaseString) && !morphiis.contains(morphii) {
                                morphiis.append(morphii)
                            }
                        }
                    }
                }
            }
        }catch {
            return []
        }
        return morphiis
    }
    
    class func getMorphiisForTagMatchingString (searchString:String?) -> [Morphii] {
        var morphiis:[Morphii] = []
        guard var string = searchString?.stringByReplacingOccurrencesOfString(" ", withString: "") else {return morphiis}
        if string == "" {
            return morphiis
        }
        string = string.stringByReplacingOccurrencesOfString("#", withString: "")
        let request = NSFetchRequest(entityName: Morphii.EntityName)
        let sort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sort]
        do {
            guard let m = try CDHelper.sharedInstance.managedObjectContext.executeFetchRequest(request) as? [Morphii] else {return []}
            for morphii in m {
                if let tagArray = morphii.tags {
                    let array = NSArray(array: tagArray)
                    if let ts = array as? [String] {
                        for tag in ts {
                            if tag.lowercaseString == string.lowercaseString && !morphiis.contains(morphii) {
                                morphiis.append(morphii)
                            }
                        }
                    }
                }
            }
        }catch {
            return []
        }
        return morphiis
    }
    
    func deleteMorphii (completion:((success:Bool)->Void)?) {
        CDHelper.sharedInstance.managedObjectContext.deleteObject(self)
        CDHelper.sharedInstance.saveContext(completion)
    }
    
    class func getMostRecentlyUsedMorphiis () -> [Morphii] {
        let request = NSFetchRequest(entityName: EntityNames.Morphii)
        let sort = NSSortDescriptor(key: "lastUsed", ascending: false)
        request.sortDescriptors = [sort]
        request.fetchLimit = 26
        request.predicate = NSPredicate(format: "lastUsed != nil")
        do {
            guard let m = try CDHelper.sharedInstance.managedObjectContext.executeFetchRequest(request) as? [Morphii] else {return []}
            return m
        }catch {
            return []
        }
    }
    
    func setLastUsedDate (date:NSDate) {
        lastUsed = date
        CDHelper.sharedInstance.saveContext(nil)
    }
    
    class func getFavoriteMorphiis () -> [Morphii] {
        let request = NSFetchRequest(entityName: Morphii.EntityName)
        let sort = NSSortDescriptor(key: "order", ascending: true)
        request.sortDescriptors = [sort]
        request.predicate = NSPredicate(format: "isFavorite == %@", NSNumber(bool: true))
        do {
            guard let morphiis = try CDHelper.sharedInstance.managedObjectContext.executeFetchRequest(request) as? [Morphii] else {return []}
            return morphiis
        }catch {
            return []
        }
    }
    
    class func getNonfavoriteMorphiis () -> [Morphii] {
        var morphiis:[Morphii] = []
        let request = NSFetchRequest(entityName: EntityNames.Morphii)
        request.predicate = NSPredicate(format: "isFavorite == %@", NSNumber(bool: false))
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
    
    class func deleteNonfavoriteMorphiis () -> Bool {
        let request = NSFetchRequest(entityName: EntityNames.Morphii)
        request.predicate = NSPredicate(format: "isFavorite == %@", NSNumber(bool: false))
        let delteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try CDHelper.sharedInstance.coordinator.executeRequest(delteRequest, withContext: CDHelper.sharedInstance.managedObjectContext)
            return true
        }catch {
            return false
        }
    }
}
