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
    static let GETURL = "\(Config.getCurrentConfig().MORPHII_API_BASE_URL)/kbapp/v1/morphiis?lastDate=\(lastDate)"
    static let LOGINURL = "\(Config.getCurrentConfig().MORPHII_API_BASE_URL)/admin/v1/login"
    static let FAVORITEURL = "\(Config.getCurrentConfig().MORPHII_API_BASE_URL)/kbapp/v1/favorites"
    
    class func fetchNewMorphiis(completion: (morphiisArray: [ Morphii ], success:Bool) -> Void ) -> Void {
        if alreadyCheckedForMorphiisToday() {
            let morphiis = Morphii.fetchAllMorphiis()
            completion(morphiisArray: morphiis, success: true)
            return
        }
        if let last = NSUserDefaults.standardUserDefaults().stringForKey(NSUserDefaultKeys.lastDate) {
            lastDate = last
        }
        guard let _ = NSURL(string: GETURL) else {
            print("INVALID_URL:",GETURL)
            return
        }
        Alamofire.request(.GET, GETURL, headers: getHeader(.GET))
            .response { request, response, data, error in
                //print("REQUEST:",request,"RESPONSE:",response,"DATA:",data,"ERROR:",error)
                let morphiis = convertJSONToMorphiis(data)
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    dispatch_async(dispatch_get_main_queue(), {
                        completion(morphiisArray: morphiis, success: error == nil)
                        
                    })
                })
        }
    }
    
    class func convertJSONToMorphiis (json:NSData?) -> [Morphii] {
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
                let _ = data.valueForKey(MorphiiAPIKeys.metaData),
                let _ = record.valueForKey(MorphiiAPIKeys.scaleType),
                let _ = record.valueForKey(MorphiiAPIKeys.id),
                let _ = record.valueForKey(MorphiiAPIKeys.name),
                let _ = record.valueForKey(MorphiiAPIKeys.sequence),
                let groupName = record.valueForKey(MorphiiAPIKeys.groupName)
                //                let _ = record.valueForKey(MorphiiAPIKeys.staticUrl)
                //                let _ = record.valueForKey(MorphiiAPIKeys.dataUrl)
                //                let _ = record.valueForKey(MorphiiAPIKeys.changedDateUTC)
                //                let _ = data.valueForKey(MorphiiAPIKeys.png)
            {
                print("GOT_MORPHII:",groupName)
                Morphii.createNewMorphii(record, emoodl: nil, isFavorite: false)
                //morphiis.append(Morphii(morphiiRecord: record))
            }
        }
        let morphiis = Morphii.fetchAllMorphiis()
        return morphiis
    }
    
    class func sendFavoriteData (completion:((success:Bool)->Void)?) {
        
    }
    
    class func getHeader (header:Headers) -> [String:String] {
        switch header {
        case .GET:
            return ["x-api-key": Config.getCurrentConfig().MORPHII_API_KEY]
        case .LOGIN:
            return ["Content­-Type": "application/json"]
        case .FAVORITES:
            return ["Content­-Type": "application/json", "x-api-key": Config.getCurrentConfig().MORPHII_API_KEY, "Authorization":"Bearer\(getToken())"]
        }
    }
    
    class func getToken () -> String {
        guard let token = NSUserDefaults.standardUserDefaults().stringForKey(NSUserDefaultKeys.token) else {return ""}
        return token
    }
    
    class func login () {
        let parameters = ["username":Config.getCurrentConfig().MORPHII_API_USER_NAME,
                          "password":Config.getCurrentConfig().MORPHII_API_PASSWORD]
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions.PrettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
            let request = NSMutableURLRequest(URL: NSURL(string: LOGINURL)!)
            request.HTTPBody = jsonData
            request.HTTPMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let queue:NSOperationQueue = NSOperationQueue()
            NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: { (response, data, error) in
                guard let d = data else {return}
                var jsonDict:NSDictionary?
                do {
                    try jsonDict = NSJSONSerialization.JSONObjectWithData(d, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                }catch {
                    print("Handle \(error) here")
                }
                guard let JSONDict = jsonDict else {return}
                if let token = JSONDict.objectForKey("token") as? String {
                    NSUserDefaults.standardUserDefaults().setObject(token, forKey: NSUserDefaultKeys.token)
                    NSUserDefaults.standardUserDefaults().synchronize()

                }
            })
        } catch let error as NSError {
            print(error)
        }
    }
    
    class func sendFavoriteData (morphiiO:Morphii?, favoriteNameO:String?) {
        guard let favoriteName = favoriteNameO, let morphii = morphiiO, let deviceId = UIDevice.currentDevice().identifierForVendor?.UUIDString, let morphiiId = morphii.id, let morphiiName = morphii.name, let intensity = morphii.emoodl?.doubleValue else {return}
        
        let accountId = Config.getCurrentConfig().MORPHII_API_ACCOUNT_ID
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY-­MM­-dd'T'HH:mm:ss.SSSZ"
        let dateString = dateFormatter.stringFromDate(NSDate())
        dateFormatter.dateFormat = "Z"
        let timeZoneOffsetString = dateFormatter.stringFromDate(NSDate())
        
        let parameters = ["account":
                            ["id":accountId],
                          "device":
                            ["id":deviceId],
                          "timestamp":
                            ["utc":dateString,
                             "offset":timeZoneOffsetString],
                          "morphii":
                            ["id":morphiiId,
                             "name":morphiiName,
                             "intensity":intensity/100],
                          "favorite":
                            ["name":favoriteName]
                          ]
        print("PARAMETERS:",parameters)
        print("FAVORITE - devicedId:",deviceId,"favoriteName:",favoriteName,"morphiiId:",morphiiId,"morphiiName:",morphiiName,"intensity:",intensity/100.0,"dateString:",dateString,"timeZoneOffset:",timeZoneOffsetString,"AccountId:",accountId)
        
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions.PrettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
            let request = NSMutableURLRequest(URL: NSURL(string: FAVORITEURL)!)
            request.HTTPBody = jsonData
            request.HTTPMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(Config.getCurrentConfig().MORPHII_API_KEY, forHTTPHeaderField: "x-api-key")
            request.setValue("Bearer\(getToken())", forHTTPHeaderField: "Authorization")
            print("APIKEY:",Config.getCurrentConfig().MORPHII_API_KEY,"TOKEN:","Bearer\(getToken())")

            let queue:NSOperationQueue = NSOperationQueue()
            NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: { (response, data, error) in
                guard let d = data else {return}
                var jsonDict:NSDictionary?
                do {
                    try jsonDict = NSJSONSerialization.JSONObjectWithData(d, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    print("JSONDICT:",jsonDict)
                }catch {
                    print("Handle \(error) here")
                }

            })
        } catch let error as NSError {
            print(error)
        }
    }
    
    enum Headers {
        case GET
        case LOGIN
        case FAVORITES
    }
}
