//
//  MorphiiAPI.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/7/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit
import Alamofire

class MorphiiAPI {
    static var lastDate = "2015-05-15"
    static let morphiisUrl = "\(Config.getCurrentConfig().MORPHII_API_BASE_URL)/kbapp/v1/morphiis?lastDate=\(lastDate)"
    static let headers = [
        "x-api-key": Config.getCurrentConfig().MORPHII_API_KEY
    ]
    
    class func fetchNewMorphiis(completion: (morphiisArray: [ Morphii ]) -> Void ) -> Void {
        if alreadyCheckedForMorphiisToday() {
            completion(morphiisArray: [])
            return
        }
        if let last = NSUserDefaults.standardUserDefaults().stringForKey(NSUserDefaultKeys.lastDate) {
            lastDate = last
        }
        guard let _ = NSURL(string: morphiisUrl) else {
            print("INVALID_URL:",morphiisUrl)
            return
        }
        Alamofire.request(.GET, morphiisUrl, headers: headers)
            .response { request, response, data, error in
                //print("REQUEST:",request,"RESPONSE:",response,"DATA:",data,"ERROR:",error)
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    let morphiis = processJSON(data)
                    dispatch_async(dispatch_get_main_queue(), { 
                        completion(morphiisArray: morphiis)

                    })
                })
        }
    }
    
    class func processJSON (json:NSData?) -> [Morphii] {
        guard let JSON = json else {return []}
        var jsonDict:NSDictionary?
        do {
            try jsonDict = NSJSONSerialization.JSONObjectWithData(JSON, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
            setLastDateToCurrentDate()
        }catch {
            print("Handle \(error) here")
        }
        guard let JSONDict = jsonDict else {return []}
        guard let records = JSONDict.objectForKey(MorphiiAPIKeys.records) as? [NSDictionary] else {return []}

        return processMorphiiDataArray(records)
    }
    
    private class func setLastDateToCurrentDate () {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        NSUserDefaults.standardUserDefaults().setObject(dateFormatter.stringFromDate(NSDate()), forKey: NSUserDefaultKeys.lastDate)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    private class func alreadyCheckedForMorphiisToday () -> Bool {
        guard let last = NSUserDefaults.standardUserDefaults().stringForKey(NSUserDefaultKeys.lastDate) else {
            return false
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        print("ALREADY_CHECKED_TODAY")
        return last == dateFormatter.stringFromDate(NSDate())
    }
    
    class func processMorphiiDataArray (morphiiRecords:[NSDictionary]) -> [Morphii] {
        
        for record in morphiiRecords {
            if let data = record.valueForKey(MorphiiAPIKeys.data) as? NSDictionary,
                let metaData = data.valueForKey(MorphiiAPIKeys.metaData),
                let _ = record.valueForKey(MorphiiAPIKeys.scaleType),
                let _ = record.valueForKey(MorphiiAPIKeys.id),
                let _ = record.valueForKey(MorphiiAPIKeys.name),
                let _ = record.valueForKey(MorphiiAPIKeys.sequence)
//                let _ = record.valueForKey(MorphiiAPIKeys.staticUrl)
//                let _ = record.valueForKey(MorphiiAPIKeys.dataUrl)
//                let _ = record.valueForKey(MorphiiAPIKeys.changedDateUTC)
//                let _ = data.valueForKey(MorphiiAPIKeys.png)
            {
                print("GOT_MORPHII:",metaData)
                Morphii.createNewMorphii(record)
                //morphiis.append(Morphii(morphiiRecord: record))
            }
        }
        let morphiis = Morphii.fetchAllMorphiis()
        return morphiis
    }
}
