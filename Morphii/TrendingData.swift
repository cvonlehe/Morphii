//
//  TrendingData.swift
//  Morphii
//
//  Created by netGALAXY Studios on 7/13/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import Foundation
import CoreData


class TrendingData: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    
    class func getTrendingData() -> TrendingData? {
        let request = NSFetchRequest(entityName: EntityNames.TrendingData)
        do {
            guard let trending = try CDHelper.sharedInstance.managedObjectContext.executeFetchRequest(request) as? [TrendingData] else {return nil}
            guard let first = trending.first else {return nil}
            return first
        }catch {
            return nil
        }
    }
    
    class func saveTrendingData (data:NSDictionary) -> Bool {
        var trendingData:TrendingData?
        if let trending = getTrendingData() {
            trendingData = trending
        }else {
            trendingData = NSEntityDescription.insertNewObjectForEntityForName(EntityNames.TrendingData, inManagedObjectContext: CDHelper.sharedInstance.managedObjectContext) as? TrendingData
        }
        if let trending = trendingData {
            trending.dictionary = NSMutableDictionary(dictionary: data)
            do {
                try CDHelper.sharedInstance.managedObjectContext.save()
                return true
            }catch {
                return false
            }
        }else {
            return false
        }
    }
    
    class func getDataFromDict (dict:NSDictionary?, completion:(newsTitle:String?, newsMessage:String?, newsURL:String?, morphiis:[Morphii]?, hashtags:[String]?, links:String?)->Void) {
        print("JSONDICT:",dict)
        var newsTitle:String?, newsMessage:String?, newsURL:String?, morphiis:[Morphii]?, hashtags:[String]?, links:String?
        
        if let news = dict?.objectForKey("news") as? NSDictionary {
            newsMessage = news.objectForKey("message") as? String
            newsURL = news.objectForKey("url") as? String
            newsTitle = news.objectForKey("title") as? String
        }
        if let morphiiArray = dict?.objectForKey("morphiis") as? [NSDictionary] {
            var ids:[String] = []
            for morphiiDict in morphiiArray {
                if let id = morphiiDict.objectForKey("id") as? String {
                    ids.append(id)
                }
            }
            morphiis = Morphii.getMorphiisForIds(ids)
            //morphiis = Morphii.getMorphiisForIds(["6132631194195460096", "6132631203339042816"])
            
        }
        hashtags = dict?.objectForKey("hashtags") as? [String]
        if let link = dict?.objectForKey("links") as? NSDictionary {
            if let selfs = link.objectForKey("self") as? NSDictionary {
                links = selfs.objectForKey("href") as? String
            }
        }
        completion(newsTitle:newsTitle, newsMessage: newsMessage, newsURL: newsURL, morphiis: morphiis, hashtags: hashtags, links: links)
    }

}
