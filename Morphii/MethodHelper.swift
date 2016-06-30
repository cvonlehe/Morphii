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
        let returningUser = NSUserDefaults.standardUserDefaults().boolForKey(NSUserDefaultKeys.returningUser)
        if !returningUser {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: NSUserDefaultKeys.returningUser)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        return returningUser
    }
    

    
    class func shouldNotAddURLToMessages () -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(NSUserDefaultKeys.shouldNotAddURLToMessages)
    }
    
    class func setShouldNotAddURLToMessages (value:Bool) {
        NSUserDefaults.standardUserDefaults().setBool(value, forKey: NSUserDefaultKeys.shouldNotAddURLToMessages)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func wiggle (view:UIView) {
        let animation = CAKeyframeAnimation(keyPath: "transform")
        let randomNumber = arc4random_uniform(9) + 1
        
        let wobbleAngle = CGFloat(Double(randomNumber) / 100.0)
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
    
}