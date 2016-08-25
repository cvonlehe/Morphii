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
import DeviceKit
import APTimeZones

class MorphiiAPI {
    static var lastDate = "2015-05-15"
    static let GETURL = "\(Config.getCurrentConfig().MORPHII_API_BASE_URL)/kbapp/v1/morphiis?lastDate=\(lastDate)"
    static let LOGINURL = "\(Config.getCurrentConfig().MORPHII_API_BASE_URL)/admin/v1/login"
    static let FAVORITEURL = "\(Config.getCurrentConfig().MORPHII_API_BASE_URL)/kbapp/v1/favorites"
    static let TRENDINGURL = "\(Config.getCurrentConfig().MORPHII_API_BASE_URL)/kbapp/v1/stats"
    static let APPVERSIONURL = "\(Config.getCurrentConfig().MORPHII_API_BASE_URL)/admin/v1/mobileApp/kb?type=ios"
    private static var awsEventClient:AWSMobileAnalyticsEventClient?
    static var currentLocation:CLLocation?
    static var keyboardActive = false
    
    class func fetchNewMorphiis(completion: (morphiisArray: [ Morphii ], success:Bool) -> Void ) -> Void {
        if alreadyCheckedForMorphiisToday() {
            let morphiis = Morphii.fetchAllMorphiis()
            completion(morphiisArray: morphiis, success: true)
            return
        }
        if let last = MorphiiAPI.getUserDefaults().stringForKey(NSUserDefaultKeys.lastDate) {
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
    
    class func getUserDefaults () -> NSUserDefaults {
        return NSUserDefaults(suiteName: "group.morphii")!
    }
    
    
    class func setupAWS () {
        let analytics = AWSMobileAnalytics(forAppId: Config.getCurrentConfig().AWS_APP_ID, identityPoolId: Config.getCurrentConfig().AWS_POOL_ID)
        if analytics != nil {
            if analytics.eventClient != nil {
                awsEventClient = analytics.eventClient
            }
        }
    }
    
    private class func sendEvent (eventClient:AWSMobileAnalyticsEventClient, event:AWSMobileAnalyticsEvent) {
        if !keyboardActive {
            MethodHelper.getCurrentLocaiton { (locationO) in
                print("sendEventAfterLocation")
                if let location = locationO {
                    
                    event.addMetric(location.coordinate.latitude, forKey: AWSAttributes.lat)
                    event.addMetric(location.coordinate.longitude, forKey: AWSAttributes.lng)
                }
                let timeZone = NSTimeZone.localTimeZone().name
                event.addAttribute(timeZone, forKey: AWSAttributes.timeZone)
                print("TIMEZONE:",timeZone)
                if let deviceId = UIDevice.currentDevice().identifierForVendor?.UUIDString {
                    print("UDID:",deviceId)
                    event.addAttribute(deviceId, forKey: AWSAttributes.deviceId)
                }else {
                    event.addAttribute("unavailable", forKey: AWSAttributes.deviceId)
                }
                eventClient.recordEvent(event)
                eventClient.submitEvents()
            }
        }else {
            if MorphiiAPI.getUserDefaults().doubleForKey(NSUserDefaultKeys.latitude) != 0 && MorphiiAPI.getUserDefaults().doubleForKey(NSUserDefaultKeys.longitude) != 0 {
                
                event.addMetric(MorphiiAPI.getUserDefaults().doubleForKey(NSUserDefaultKeys.latitude), forKey: AWSAttributes.lat)
                event.addMetric(MorphiiAPI.getUserDefaults().doubleForKey(NSUserDefaultKeys.longitude), forKey: AWSAttributes.lng)
            }
            let timeZone = NSTimeZone.localTimeZone().name
            event.addAttribute(timeZone, forKey: AWSAttributes.timeZone)
            print("TIMEZONE:",timeZone)
            if let deviceId = UIDevice.currentDevice().identifierForVendor?.UUIDString {
                print("UDID:",deviceId)
                event.addAttribute(deviceId, forKey: AWSAttributes.deviceId)
            }else {
                event.addAttribute("unavailable", forKey: AWSAttributes.deviceId)
            }
            eventClient.recordEvent(event)
            eventClient.submitEvents()
        }
        
    }
    
    
    class func getCorrectedIntensity (intensity:NSNumber, scaleType:Int) -> NSNumber {
        var newIntensity = NSNumber(int: 0)
        if intensity.intValue <= 0 {
            newIntensity = NSNumber(int: 0)
        }else if intensity.intValue > 100 {
            newIntensity = NSNumber(int: 100)
        }
        if intensity.intValue > 1 {
            newIntensity = NSNumber(double: intensity.doubleValue / 100)
        }
        if scaleType == 1 {
            newIntensity = NSNumber(float: (1.0 - newIntensity.floatValue))
        }
        return newIntensity
    }
    
    class func sendMorphiiSelectedToAWS (morphii:Morphii, area:String) {
        print("sendMorphiiSelectedToAWS1")
        guard let eventClient = awsEventClient else {return}
        print("sendMorphiiSelectedToAWS2")
        let event = eventClient.createEventWithEventType(AWSEvents.MorphiiSelect)
        guard event != nil else {return}
        print("sendMorphiiSelectedToAWS3")
        guard let id = morphii.id, let name = morphii.name, let intensity = morphii.emoodl, let scaleType = morphii.scaleType?.integerValue else {return}
        print("sendMorphiiSelectedToAWS4")
        if let originalId = morphii.originalId {
            event.addAttribute(originalId, forKey: AWSAttributes.id)
        }else {
            event.addAttribute(id, forKey: AWSAttributes.id)
        }
        
        if let originalName = morphii.originalName {
            event.addAttribute(originalName, forKey: AWSAttributes.name)
            if originalName != name {
                event.addAttribute(name, forKey: AWSAttributes.userProvidedName)
            }
        }else {
            event.addAttribute(name, forKey: AWSAttributes.name)
        }
        if area != MorphiiAreas.containerHome && area != MorphiiAreas.keyboardHome && area != MorphiiAreas.containerTrending {
            event.addMetric(getCorrectedIntensity(intensity, scaleType: scaleType), forKey: AWSAttributes.intensity)
            print("SAVEDINTENSITY - 1:",getCorrectedIntensity(intensity, scaleType: scaleType))
            if let tags = morphii.tags, let isFavroite = morphii.isFavorite?.boolValue {
                if isFavroite {
                    event.addAttribute(tags.componentsJoinedByString(", "), forKey: AWSAttributes.userProvidedTags)
                }
            }
        }else {
            print("SAVEDINTENSITY - 2:",0.5)
            event.addMetric(0.5, forKey: AWSAttributes.intensity)
        }
        
        event.addAttribute(area, forKey: AWSAttributes.area)
        sendEvent(eventClient, event: event)
    }
    
    class func sendIntensityChangeToAWS (morphii:Morphii, beginIntensity:NSNumber, endIntensity:NSNumber, area:String?) {
        guard let eventClient = awsEventClient else {return}
        let event = eventClient.createEventWithEventType(AWSEvents.MorphiiChangeIntensity)
        guard event != nil else {return}
        guard let id = morphii.id, let name = morphii.name, let scaleType = morphii.scaleType?.integerValue else {return}
        if let originalId = morphii.originalId {
            event.addAttribute(originalId, forKey: AWSAttributes.id)
        }else {
            event.addAttribute(id, forKey: AWSAttributes.id)
        }
        
        if let originalName = morphii.originalName {
            event.addAttribute(originalName, forKey: AWSAttributes.name)
            if originalName != name {
                event.addAttribute(name, forKey: AWSAttributes.userProvidedName)
            }
        }else {
            event.addAttribute(name, forKey: AWSAttributes.name)
        }
        if let a = area {
            event.addAttribute(a, forKey: AWSAttributes.area)
        }
        if area != MorphiiAreas.containerHome && area != MorphiiAreas.keyboardHome && area != MorphiiAreas.containerTrending {
            if let tags = morphii.tags, let isFavroite = morphii.isFavorite?.boolValue {
                if isFavroite {
                    event.addAttribute(tags.componentsJoinedByString(", "), forKey: AWSAttributes.userProvidedTags)
                }
            }
        }
        print("INTENSITYCHANGE:",getCorrectedIntensity(beginIntensity, scaleType: scaleType))
        print("INTENSITYCHANGE:",getCorrectedIntensity(endIntensity,scaleType: scaleType))
        
        event.addMetric(getCorrectedIntensity(beginIntensity, scaleType: scaleType), forKey: AWSAttributes.begin)
        event.addMetric(getCorrectedIntensity(endIntensity, scaleType: scaleType), forKey: AWSAttributes.end)
        sendEvent(eventClient, event: event)
        
    }
    
    class func sendMorphiiFavoriteSavedToAWS (morphii:Morphii, intensity:NSNumber, area:String?, name:String, originalName:String?, tags:[String]) {
        guard let eventClient = awsEventClient else {return}
        let event = eventClient.createEventWithEventType(AWSEvents.MorphiiFavoriteSave)
        guard event != nil else {return}
        guard let id = morphii.id, let scaleType = morphii.scaleType?.integerValue else {return}
        if let originalId = morphii.originalId {
            event.addAttribute(originalId, forKey: AWSAttributes.id)
        }else {
            event.addAttribute(id, forKey: AWSAttributes.id)
        }
        
        if let originalName = morphii.originalName {
            event.addAttribute(originalName, forKey: AWSAttributes.name)
            if originalName != name {
                event.addAttribute(name, forKey: AWSAttributes.userProvidedName)
            }
        }else {
            event.addAttribute(name, forKey: AWSAttributes.name)
        }
        if let a = area {
            event.addAttribute(a, forKey: AWSAttributes.area)
        }
        let tagString = tags.joinWithSeparator(", ")
        event.addAttribute(tagString, forKey: AWSAttributes.userProvidedTags)
        event.addMetric(getCorrectedIntensity(intensity, scaleType: scaleType), forKey: AWSAttributes.intensity)
        sendEvent(eventClient, event: event)
        
    }
    
    class func sendMorphiiSendToAWS (morphii:Morphii, intensity:NSNumber, area:String?, name:String, share:String) {
        print("sendMorphiiSendToAWS:Area:",area)
        guard let eventClient = awsEventClient else {return}
        let event = eventClient.createEventWithEventType(AWSEvents.MorphiiShareSelect)
        guard event != nil else {return}
        guard let id = morphii.id, let name = morphii.name, let scaleType = morphii.scaleType?.integerValue else {return}
        if let originalName = morphii.originalName {
            event.addAttribute(originalName, forKey: AWSAttributes.name)
            if originalName != name {
                event.addAttribute(name, forKey: AWSAttributes.userProvidedName)
            }
        }else {
            event.addAttribute(name, forKey: AWSAttributes.name)
        }
        event.addAttribute(share, forKey: AWSAttributes.share)
        if let a = area {
            event.addAttribute(a, forKey: AWSAttributes.area)
        }
        if let originalId = morphii.originalId {
            event.addAttribute(originalId, forKey: AWSAttributes.id)
        }else {
            event.addAttribute(id, forKey: AWSAttributes.id)
        }
        if let favorite = morphii.isFavorite?.boolValue {
            if favorite {
                var tags:[String] = []
                if let userTags = morphii.tags {
                    for object in userTags {
                        if object is String {
                            tags.append(object as! String)
                        }
                    }
                }
                let tagString = tags.joinWithSeparator(", ")
                event.addAttribute(tagString, forKey: AWSAttributes.userProvidedTags)
                
            }
        }
        event.addMetric(getCorrectedIntensity(intensity, scaleType: scaleType), forKey: AWSAttributes.intensity)
        sendEvent(eventClient, event: event)
        
    }

    
    class func sendUserProfileChangeToAWS (propertyName:String, begin:Bool, end:Bool) {
        guard let eventClient = awsEventClient else {return}
        let event = eventClient.createEventWithEventType(AWSEvents.UserProfileChange)
        guard event != nil else {return}
        event.addAttribute(propertyName, forKey: AWSAttributes.name)
        var beginString = "false"
        if begin {
            beginString = "true"
        }
        var endString = "false"
        if end {
            endString = "true"
        }
        event.addAttribute(beginString, forKey: AWSAttributes.begin)
        event.addAttribute(endString, forKey: AWSAttributes.end)
        sendEvent(eventClient, event: event)
        
    }
    
    class func sendUserProfileActionToAWS (actionName:String) {
        guard let eventClient = awsEventClient else {return}
        let event = eventClient.createEventWithEventType(AWSEvents.UserProfileAction)
        guard event != nil else {return}
        event.addAttribute(actionName, forKey: AWSAttributes.name)
        sendEvent(eventClient, event: event)
        
    }
    
    class func syncAWS () {
        guard let eventClient = awsEventClient else {return}
        eventClient.submitEvents()
    }
    
    class AWSEvents {
        static let MorphiiSelect = "morphii-change"
        static let MorphiiChangeIntensity = "morphii-intensity-change"
        static let MorphiiFavoriteSave = "morphii-favorite-save"
        static let MorphiiShareSelect = "morphii-share-select"
        static let UserProfileChange = "user-profile-change"
        static let UserProfileAction = "user-profile-action"
    }
    class AWSAttributes {
        static let id = "id"
        static let name = "name"
        static let intensity = "intensity"
        static let begin = "begin"
        static let end = "end"
        static let area = "area"
        static let userProvidedName = "user-provided-name"
        static let userProvidedTags = "user-provided-tags"
        static let share = "share"
        static let lat = "lat"
        static let lng = "lng"
        static let deviceId = "deviceId"
        static let timeZone = "timeZone"
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
        MorphiiAPI.getUserDefaults().setObject(dateFormatter.stringFromDate(NSDate()), forKey: NSUserDefaultKeys.lastDate)
        MorphiiAPI.getUserDefaults().synchronize()
    }
    
    private class func alreadyCheckedForMorphiisToday () -> Bool {
        guard let last = MorphiiAPI.getUserDefaults().stringForKey(NSUserDefaultKeys.lastDate) else {
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
                //print("GOT_MORPHII:",record)
                var emoodl:Double?
                if let group = groupName as? String {
                    if group == "EmojiOne" {
                        emoodl = 100.0
                    }
                }
                var showName = true
                if let show = record.valueForKey(MorphiiAPIKeys.showName) as? Bool {
                    print("show123:",show)
                    showName = show
                }
                Morphii.createNewMorphii(record, emoodl: emoodl, isFavorite: false, showName: showName)
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
        guard let token = MorphiiAPI.getUserDefaults().stringForKey(NSUserDefaultKeys.token) else {return ""}
        return token
    }
    
    class func login () {
        let parameters = ["username":Config.getCurrentConfig().MORPHII_API_USER_NAME,
                          "password":Config.getCurrentConfig().MORPHII_API_PASSWORD]
        do {
            print("PARAMETERS:",parameters)
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
                    print("loginHandle \(error) here")
                }
                guard let JSONDict = jsonDict else {return}
                print("login1:",JSONDict)
                if let token = JSONDict.objectForKey("token") as? String {
                    print("login2")
                    MorphiiAPI.getUserDefaults().setObject(token, forKey: NSUserDefaultKeys.token)
                    MorphiiAPI.getUserDefaults().synchronize()
                    
                }else {
                    print("login3")
                }
            })
        } catch let error as NSError {
            print(error)
        }
    }
    
    class func sendFavoriteData (morphiiO:Morphii?, favoriteNameO:String?, emoodl:Double, tags:[String], intensity:Double) {
        print("sendFavoriteData1346:",intensity)

        if keyboardActive {
            sendFavoritePOST(nil, morphiiO: morphiiO, favoriteNameO: favoriteNameO, emoodl: emoodl, tags: tags, intensity: intensity)
        }else {
            MethodHelper.getCurrentLocaiton { (locationO) in
                sendFavoritePOST(locationO, morphiiO: morphiiO, favoriteNameO: favoriteNameO, emoodl: emoodl, tags: tags, intensity: intensity)
            }
        }
        
    }
    
    private class func sendFavoritePOST (locationO:CLLocation?, morphiiO:Morphii?, favoriteNameO:String?, emoodl:Double, tags:[String], intensity:Double) {
        guard let favoriteName = favoriteNameO, let morphii = morphiiO, let deviceId = UIDevice.currentDevice().identifierForVendor?.UUIDString, var morphiiId = morphii.id, var morphiiName = morphii.name, let scaleType = morphii.scaleType?.integerValue else {return}
        print("sendFavoriteData2")
        let accountIdString = Config.getCurrentConfig().MORPHII_API_ACCOUNT_ID.stringByReplacingOccurrencesOfString(" ", withString: "")
        if let id = morphii.originalId, let name = morphii.originalName {
            morphiiName = name
            morphiiId = id
        }
        //        var index = 0
        //        var characters:[String] = []
        //        for character in accountIdString.characters {
        //            if index != 4{
        //                characters.append("\(character)")
        //            }
        //            index += 1
        //        }
        //        let accountId = characters.joinWithSeparator("")
        let accountId = accountIdString
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSSZ"
        let dateString = dateFormatter.stringFromDate(NSDate())
        dateFormatter.dateFormat = "Z"
        let timeZoneOffsetString = dateFormatter.stringFromDate(NSDate())
        var lat:Double = 0
        var lng:Double = 0
        if let location = locationO {
            lat = location.coordinate.latitude
            lng = location.coordinate.longitude
        }else {
            if MorphiiAPI.getUserDefaults().doubleForKey(NSUserDefaultKeys.latitude) != 0 && MorphiiAPI.getUserDefaults().doubleForKey(NSUserDefaultKeys.longitude) != 0 {
                
                lat = MorphiiAPI.getUserDefaults().doubleForKey(NSUserDefaultKeys.latitude)
                lng = MorphiiAPI.getUserDefaults().doubleForKey(NSUserDefaultKeys.longitude)
            }
        }
        let intensityNumber = getCorrectedIntensity(NSNumber(double: intensity), scaleType: scaleType)
        print("FAVORITEINTENSITY:",intensityNumber,"SCALETYPE:",scaleType)
        let make = getMake()
        let model = "\(Device())"
        let parameters = ["account":
            ["id":accountId],
                          "device":
                            ["id":deviceId,
                                "manufacturer":"Apple",
                                "make":make,
                                "model":model,
                                "firmware":Device().systemVersion],
                          "client":[
                            "lat":lat,
                            "lng":lng],
                          "timestamp":
                            ["utc":dateString,
                                "offset":timeZoneOffsetString],
                          "morphii":
                            ["id":morphiiId,
                                "name":morphiiName,
                                "intensity":intensityNumber],
                          "favorite":
                            ["name":favoriteName,
                                "tags":tags]
        ]
        print("PARAMETERS123:",parameters)
//        print("FAVORITE123 - devicedId:",deviceId,"favoriteName:",favoriteName,"morphiiId:",morphiiId,"morphiiName:",morphiiName,"intensity:",intensity,"dateString:",dateString,"timeZoneOffset:",timeZoneOffsetString,"AccountId:",accountId)
        
        do {
            print("sendFavoriteData3")
            
            let data = try NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions.init(rawValue: 0))
            let asciiCode = ("-" as NSString).characterAtIndex(0)
            print("sendFavoriteData4")
            guard let string = NSString(data: data, encoding: NSUTF8StringEncoding) else {return}
            print("sendFavoriteData5")
            guard let jsonData = string.dataUsingEncoding(NSUTF8StringEncoding) else {return}
            print("sendFavoriteData6")
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
                print("sendFavoriteData7")
                guard let d = data else {return}
                print("sendFavoriteData8")
                var jsonDict:NSDictionary?
                do {
                    print("sendFavoriteData9")
                    try jsonDict = NSJSONSerialization.JSONObjectWithData(d, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    print("sendFavoriteData10")
                    
                    print("JSONDICT:",jsonDict)
                    
                }catch {
                    print("Handle \(error) here")
                }
                
            })
        } catch let error as NSError {
            print(error)
        }
    }
    
    class func getMake () -> String {
        var make = "Other"
        let device = Device()
        if device.isPod {
            make = "iPod"
        } else if device.isPhone {
            make = "iPhone"
        } else if device.isPad {
            make = "iPad"
        }
        return make
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
            print("checkIfAppIsUpdated4 DATA:",dataO,"RESPONSE:",responseO,"ERRPR:",errorO)
            guard let data = dataO else {
                completion(updated: true)
                return
            }
            print("checkIfAppIsUpdated5")
            var jsonDict:NSDictionary?
            do {
                try jsonDict = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                print("checkIfAppIsUpdated:",jsonDict, "version:",versionString)
                guard let minVersionString = jsonDict?.objectForKey("minVersion") as? String else {
                    completion(updated: true)
                    return
                }
                print("VERSION_STRING:",addUpVersionOrBuildString(versionString),"MIN_VERSION:",addUpVersionOrBuildString(minVersionString))
                if addUpVersionOrBuildString(versionString) >= addUpVersionOrBuildString(minVersionString) {
                    print("checkIfAppIsUpdated6")
                    completion(updated: true)
                }else {
                    print("checkIfAppIsUpdated7")
                    completion(updated: false)
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
