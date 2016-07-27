//
//  Config.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/9/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit

class Config: NSObject {
    private static var currentConfig:Config!
    
    var MORPHII_API_KEY = ""
    var MORPHII_API_BASE_URL = ""
    var MORPHII_API_ACCOUNT_ID = ""
    var MORPHII_API_USER_NAME = ""
    var MORPHII_API_PASSWORD = ""
    var appStoreUrl = "https://itunes.apple.com/us/app/netgalaxy-studios/id1114136380?ls=1&mt=8"
    var AWS_APP_ID = ""
    var AWS_POOL_ID = ""

    init(dictionary:NSDictionary?) {
        super.init()
        print("DICTIONARY:",dictionary)
        guard let pfConfig = dictionary else {return}
        if let api = pfConfig.objectForKey(PFConfigValues.MORPHII_API_KEY) as? String {
            MORPHII_API_KEY = api
        }
        if let base = pfConfig.objectForKey(PFConfigValues.MORPHII_API_BASE_URL) as? String {
            MORPHII_API_BASE_URL = base
        }
        if let account = pfConfig.objectForKey(PFConfigValues.MORPHII_API_ACCOUNT_ID) as? String {
            MORPHII_API_ACCOUNT_ID = account
        }
        if let username = pfConfig.objectForKey(PFConfigValues.MORPHII_API_USER_NAME) as? String {
            MORPHII_API_USER_NAME = username
        }
        if let password = pfConfig.objectForKey(PFConfigValues.MORPHII_API_PASSWORD) as? String {
            MORPHII_API_PASSWORD = password
        }
        if let url = pfConfig.objectForKey(PFConfigValues.appStoreUrl) as? String {
            self.appStoreUrl = url
        }
        if let appId = pfConfig.objectForKey(PFConfigValues.AWS_APP_ID) as? String {
            self.AWS_APP_ID = appId
        }
        if let poolId = pfConfig.objectForKey(PFConfigValues.AWS_POOL_ID) as? String {
            self.AWS_POOL_ID = poolId
        }
    }
    
    class func getCurrentConfig () -> Config {
        if currentConfig == nil {
            var dict:NSDictionary?
            if let path = NSBundle.mainBundle().pathForResource("prod-credentials", ofType: "txt") {
                print("getCurrentConfig1")
                do {
                    let string = try String(contentsOfFile: path)
                    if let data = string.dataUsingEncoding(NSUTF8StringEncoding) {
                        print("getCurrentConfig2")
                        do {
                            let jsonDict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                            print("getCurrentConfig3")
                            dict = jsonDict
                        }catch {}
                    }
                }catch {}
            }
            currentConfig = Config(dictionary: dict)
        }
        print("MORPHII_API_KEY:",currentConfig.MORPHII_API_KEY,"MORPHII_API_BASE_URL:",currentConfig.MORPHII_API_BASE_URL,"MORPHII_API_ACCOUNT_ID:",currentConfig.MORPHII_API_ACCOUNT_ID,"MORPHII_API_USER_NAME:",currentConfig.MORPHII_API_USER_NAME,"MORPHII_API_PASSWORD:",currentConfig.MORPHII_API_PASSWORD,"AWS_APP_ID:",currentConfig.AWS_APP_ID,"AWS_POOL_ID:",currentConfig.AWS_POOL_ID)
        return currentConfig
    }
}
