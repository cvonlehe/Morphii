//
//  MorphiiAPI.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/7/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit
import Alamofire
import AWSMobileAnalytics
import CoreLocation

class MorphiiAPI {
    static var lastDate = "2015-05-15"
    static let GETURL = "\(Config.getCurrentConfig().MORPHII_API_BASE_URL)/kbapp/v1/morphiis?lastDate=\(lastDate)"
    static let LOGINURL = "\(Config.getCurrentConfig().MORPHII_API_BASE_URL)/admin/v1/login"
    static let FAVORITEURL = "\(Config.getCurrentConfig().MORPHII_API_BASE_URL)/kbapp/v1/favorites"
    static let TRENDINGURL = "\(Config.getCurrentConfig().MORPHII_API_BASE_URL)/kbapp/v1/stats"
    static let APPVERSIONURL = "\(Config.getCurrentConfig().MORPHII_API_BASE_URL)/admin/v1/mobileApp/kb?type=ios"
    private static var awsEventClient:AWSMobileAnalyticsEventClient?
   static var currentLocation:CLLocation?


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
    
    class func setupAWS () {
        let analytics = AWSMobileAnalytics(forAppId: Config.getCurrentConfig().AWS_APP_ID, identityPoolId: Config.getCurrentConfig().AWS_POOL_ID)
        if analytics != nil {
            if analytics.eventClient != nil {
                awsEventClient = analytics.eventClient
            }
        }
    }
    
    class func sendMorphiiSelectedToAWS (morphii:Morphii) {
        guard let eventClient = awsEventClient else {return}
        let event = eventClient.createEventWithEventType(AWSEvents.MorphiiSelect)
        guard event != nil else {return}
        guard let id = morphii.id, let name = morphii.name, let intensity = morphii.emoodl else {return}
        event.addAttribute(id, forKey: AWSAttributes.morphiiId)
        event.addAttribute(name, forKey: AWSAttributes.morphiiName)
        event.addMetric(intensity, forKey: AWSAttributes.morphiiIntensity)
        eventClient.recordEvent(event)
        eventClient.submitEvents()
    }
    
    class func sendIntensityChangeToAWS (morphii:Morphii, beginIntensity:NSNumber, endIntensity:NSNumber) {
        guard let eventClient = awsEventClient else {return}
        let event = eventClient.createEventWithEventType(AWSEvents.MorphiiSelect)
        guard event != nil else {return}
        guard let id = morphii.id, let name = morphii.name else {return}
        event.addAttribute(id, forKey: AWSAttributes.morphiiId)
        event.addAttribute(name, forKey: AWSAttributes.morphiiName)
        event.addMetric(beginIntensity, forKey: AWSAttributes.beginIntensity)
        event.addMetric(endIntensity, forKey: AWSAttributes.endIntensity)
        eventClient.recordEvent(event)
        eventClient.submitEvents()
    }
    
    class AWSEvents {
        static let MorphiiSelect = "MorphiiSelect"
    }
    
    class AWSAttributes {
        static let morphiiId = "morphiiId"
        static let morphiiName = "morphiiName"
        static let morphiiIntensity = "morphiiIntensity"
        static let beginIntensity = "beginIntensity"
        static let endIntensity = "endIntensity"
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
                var emoodl:Double?
                if let group = groupName as? String {
                    if group == "EmojiOne" {
                        emoodl = 150.0
                    }
                }
                Morphii.createNewMorphii(record, emoodl: emoodl, isFavorite: false)
                //morphiis.append(Morphii(morphiiRecord: record))
            }
        }
        let morphiis = Morphii.fetchAllMorphiis()
        return morphiis
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
    
   class func sendFavoriteData (morphiiO:Morphii?, favoriteNameO:String?, emoodl:Double, tags:[String]) {
        guard let favoriteName = favoriteNameO, let morphii = morphiiO, let deviceId = UIDevice.currentDevice().identifierForVendor?.UUIDString, let morphiiId = morphii.id, let morphiiName = morphii.name, let intensity = morphii.emoodl?.doubleValue else {return}
        let accountIdString = Config.getCurrentConfig().MORPHII_API_ACCOUNT_ID.stringByReplacingOccurrencesOfString(" ", withString: "")
        var index = 0
        var characters:[String] = []
        for character in accountIdString.characters {
            if index != 4{
                characters.append("\(character)")
            }
            index += 1
        }
        let accountId = characters.joinWithSeparator("")
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSSZ"
        let dateString = dateFormatter.stringFromDate(NSDate())
        dateFormatter.dateFormat = "Z"
        let timeZoneOffsetString = dateFormatter.stringFromDate(NSDate())
        var versionString = ""
      if let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String {
         versionString = version
      }
      MethodHelper.getCurrentLocaiton { (locationO) in
         print("LOCATION:",locationO)
         var lat:Double = 0
         var lng:Double = 0
         if let location = locationO {
            lat = location.coordinate.latitude
            lng = location.coordinate.longitude
         }
         let device = UIDevice.currentDevice().model
         let model = UIDevice.currentDevice().name
         let parameters = ["account":
            ["id":accountId],
            "device":
               ["id":deviceId,
                  "manufacturer":"Apple",
                  "make":device,
                  "model":model,
                  "firmware":versionString],
            "client":[
               "lat":lat,
               "lng":lng],
            "timestamp":
               ["utc":dateString,
                  "offset":timeZoneOffsetString],
            "morphii":
               ["id":morphiiId,
                  "name":morphiiName,
                  "intensity":emoodl/100],
            "favorite":
               ["name":favoriteName,
                  "tags":tags]
         ]
         print("PARAMETERS:",parameters)
         print("FAVORITE - devicedId:",deviceId,"favoriteName:",favoriteName,"morphiiId:",morphiiId,"morphiiName:",morphiiName,"intensity:",intensity/100.0,"dateString:",dateString,"timeZoneOffset:",timeZoneOffsetString,"AccountId:",accountId)
         
         do {
            
            let data = try NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions.init(rawValue: 0))
            let asciiCode = ("-" as NSString).characterAtIndex(0)
            print("sendFavoriteData1:",asciiCode)
            guard let string = NSString(data: data, encoding: NSUTF8StringEncoding) else {return}
            print("sendFavoriteData2")
            guard let jsonData = string.dataUsingEncoding(NSUTF8StringEncoding) else {return}
            print("sendFavoriteData3")
            // here "jsonData" is the dictionary encoded in JSON data
            let request = NSMutableURLRequest(URL: NSURL(string: FAVORITEURL)!)
            request.HTTPBody = jsonData
            request.HTTPMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(Config.getCurrentConfig().MORPHII_API_KEY, forHTTPHeaderField: "x-api-key")
            request.setValue("Bearer \(getToken())", forHTTPHeaderField: "Authorization")
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
    }
   
    enum Headers {
        case GET
        case LOGIN
        case FAVORITES
    }
   
    class func getTrendingData (completion:(dictO:NSDictionary?)->Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: TRENDINGURL)!)
        request.HTTPMethod = "GET"
        request.setValue(Config.getCurrentConfig().MORPHII_API_KEY, forHTTPHeaderField: "x-api-key")
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue()) { (responseO, dataO, errorO) in
            guard let data = dataO else {
                completion(dictO: nil)
                return
            }
            var jsonDict:NSDictionary?
            do {
                try jsonDict = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                
                if let json = jsonDict {
                    TrendingData.saveTrendingData(json)
                }
                completion(dictO: nil)
            }catch {
                print("Handle \(error) here")
            }
        }
    }
    
    class func checkIfAppIsUpdated (completion:(updated:Bool)->Void) {
        print("checkIfAppIsUpdated1")
        guard let versionString = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String else {
            completion(updated: true)
            return
        }
        print("checkIfAppIsUpdated2")

        print("checkIfAppIsUpdated3")
        let request = NSMutableURLRequest(URL: NSURL(string: APPVERSIONURL)!)
        request.HTTPMethod = "GET"
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue()) { (responseO, dataO, errorO) in
            print("checkIfAppIsUpdated4")
            guard let data = dataO else {
                completion(updated: true)
                return
            }
            print("checkIfAppIsUpdated5")
            var jsonDict:NSDictionary?
            do {
                try jsonDict = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                print("checkIfAppIsUpdated:",jsonDict)
                guard let minVersionString = jsonDict?.objectForKey("minVersion") as? String else {
                    completion(updated: true)
                    return
                }
                print("VERSION_STRING:",addUpVersionOrBuildString(versionString),"MIN_VERSION:",addUpVersionOrBuildString(minVersionString))
                if addUpVersionOrBuildString(versionString) < addUpVersionOrBuildString(minVersionString) {
                    completion(updated: false)
                }else {
                    completion(updated: true)
                }
            }catch {
                print("Handle \(error) here")
                completion(updated: true)

            }
        }
    }
    
    class func addUpVersionOrBuildString (versionBuildString:String) -> Int {
        let stringArray = versionBuildString.componentsSeparatedByString(".")
        var multiplier = 100000
        var sum = 0
        for string in stringArray {
            if let value = Int(string) {
                sum = sum + (value * multiplier)
            }
            multiplier = multiplier / 10
        }
        return sum
    }
}
