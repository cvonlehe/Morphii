//
//  Config.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/9/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit
import Parse

class Config: NSObject {
    private static var currentConfig:Config!
    
    var MORPHII_API_KEY = ""
    var MORPHII_API_BASE_URL = ""
    var MORPHII_API_ACCOUNT_ID = ""
    var MORPHII_API_USER_NAME = ""
    var MORPHII_API_PASSWORD = ""

    init(pfConfig:PFConfig) {
        super.init()
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
    }
    
    class func getCurrentConfig () -> Config {
        if currentConfig == nil {
            currentConfig = Config(pfConfig: PFConfig.currentConfig())
            PFConfig.getConfigInBackgroundWithBlock({ (configO, errorO) in
                if let config = configO {
                    self.currentConfig = Config(pfConfig: config)
                }
            })
        }
        return currentConfig
    }
}
