//
//  MethodHelper.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/6/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import Foundation
import UIKit
import JGProgressHUD
import CoreLocation
import Parse

class MethodHelper {
    private static var hud = JGProgressHUD(style: JGProgressHUDStyle.Dark)
    
    class func showAlert (title:String, message:String) {
//        let alertView = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "Ok")
//        alertView.show()
    }
    
    class func showHudWithMessage (message:String, view:UIView) {
        self.hud.textLabel.text = message
        self.hud.showInView(view)
    }
    
    class func hideHUD () {
        self.hud.dismiss()
    }
    
    class func showSuccessErrorHUD (forSuccess:Bool, message:String, inView:UIView) {
        let hud = JGProgressHUD(style: .Light)
        hud.textLabel.text = message
        if forSuccess {
            hud.indicatorView = JGProgressHUDImageIndicatorView(image: UIImage(named: "check_mark")!)
        }else {
            hud.indicatorView = JGProgressHUDImageIndicatorView(image: UIImage(named: "close_icon")!)
        }
        hud.showInView(inView)
        hud.dismissAfterDelay(2.0)
    }
    
    class func isReturningUser () -> Bool {
        let returningUser = MorphiiAPI.getUserDefaults().boolForKey(NSUserDefaultKeys.returningUser)
        if !returningUser {
            MorphiiAPI.getUserDefaults().setBool(true, forKey: NSUserDefaultKeys.returningUser)
            MorphiiAPI.getUserDefaults().synchronize()
        }
        return returningUser
    }
    

    
    class func shouldNotAddURLToMessages () -> Bool {
        return MorphiiAPI.getUserDefaults().boolForKey(NSUserDefaultKeys.shouldNotAddURLToMessages)
    }
    
    class func setShouldNotAddURLToMessages (value:Bool) {
        MorphiiAPI.getUserDefaults().setBool(value, forKey: NSUserDefaultKeys.shouldNotAddURLToMessages)
        MorphiiAPI.getUserDefaults().synchronize()
    }
    
    class func wiggle (view:UIView) {
        let animation = CAKeyframeAnimation(keyPath: "transform")
        let wobbleAngle = CGFloat(0.06)
        let valLeft = NSValue(CATransform3D: CATransform3DMakeRotation(wobbleAngle, 0, 0, 1.0))
        let valRight = NSValue(CATransform3D: CATransform3DMakeRotation(-wobbleAngle, 0, 0, 1.0))
        animation.values = [valLeft, valRight]
        animation.autoreverses = true
        animation.duration = 0.125
        animation.repeatCount  = HUGE
        view.layer.addAnimation(animation, forKey: "")
    }
    
    class func stopWiggle (view:UIView) {
        view.layer.removeAllAnimations()
    }
    
    class func openAccessIsGranted () -> Bool {
        guard let containerPath = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.morphii")?.path else {return false}
        
        do {
            try NSFileManager.defaultManager().contentsOfDirectoryAtPath(containerPath)
            return true
        }catch {
            return false
        }
    }
   
   class func getCurrentLocaiton (completion:(locationO:CLLocation?)->Void) {
      if let location = MorphiiAPI.currentLocation {
        MorphiiAPI.getUserDefaults().setDouble(location.coordinate.latitude, forKey: NSUserDefaultKeys.latitude)
        MorphiiAPI.getUserDefaults().setDouble(location.coordinate.longitude, forKey: NSUserDefaultKeys.longitude)
        MorphiiAPI.getUserDefaults().synchronize()
         completion(locationO: location)
      }else {
         PFGeoPoint.geoPointForCurrentLocationInBackground({ (geoPointO, error) -> Void in
            if let geoPoint = geoPointO {
               let location = CLLocation(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
               MorphiiAPI.currentLocation = location
                MorphiiAPI.getUserDefaults().setDouble(geoPoint.latitude, forKey: NSUserDefaultKeys.latitude)
                MorphiiAPI.getUserDefaults().setDouble(geoPoint.longitude, forKey: NSUserDefaultKeys.longitude)
                MorphiiAPI.getUserDefaults().synchronize()
            }
            completion(locationO: MorphiiAPI.currentLocation)
            
         })
      }
      
   }
   
}