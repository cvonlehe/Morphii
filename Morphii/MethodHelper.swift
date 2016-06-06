//
//  MethodHelper.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/6/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import Foundation
import UIKit

class MethodHelper {
    class func isReturningUser () -> Bool {
        let returningUser = NSUserDefaults.standardUserDefaults().boolForKey(NSUserDefaultKeys.returningUser)
        if !returningUser {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: NSUserDefaultKeys.returningUser)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        return returningUser
    }
    
    class func openURLInDefaultBrowser (url:String) {
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
    }
    
    class func shouldNotAddURLToMessages () -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(NSUserDefaultKeys.shouldNotAddURLToMessages)
    }
    
    class func setShouldNotAddURLToMessages (value:Bool) {
        NSUserDefaults.standardUserDefaults().setBool(value, forKey: NSUserDefaultKeys.shouldNotAddURLToMessages)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}