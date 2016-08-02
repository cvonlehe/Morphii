//
//  AppDelegate.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/2/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit
import CoreData
import Fabric
import Crashlytics
import Parse
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
   let locationManager = CLLocationManager()

    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        displayMainView()
        MorphiiAPI.login()
        Config.getCurrentConfig()
        

        return true
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        BuddyBuildSDK.setup()
        
        // Override point for customization after application launch.
        Fabric.with([Crashlytics.self])
        MorphiiAPI.setupAWS()
      locationManager.delegate = self
      locationManager.requestWhenInUseAuthorization()
      locationManager.startUpdatingLocation()
        MorphiiAPI.syncAWS()
        return true
    }
    


    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        MorphiiAPI.syncAWS()

    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        MorphiiAPI.syncAWS()

    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        CDHelper.sharedInstance.saveContext(nil)
        MorphiiAPI.syncAWS()
    }
    
    //MARK: - SETUP Main View
    
    func displayMainView () {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let centerView = mainStoryboard.instantiateViewControllerWithIdentifier(ViewControllerIDs.TabBarController) as! UITabBarController
        centerView.delegate = self
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        appDelegate.window?.rootViewController = centerView
        appDelegate.window?.makeKeyAndVisible()
    }
   
   func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      if locations.count > 0 {
         MorphiiAPI.currentLocation = locations.first
         locationManager.stopUpdatingLocation()
      }
   }

}

extension AppDelegate:UITabBarControllerDelegate {
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        guard let currentController = tabBarController.selectedViewController as? UINavigationController else {return true}
        currentController.popToRootViewControllerAnimated(false)
        return true
    }
}

extension UIApplication {
    
    func safeSharedApplication() -> UIApplication? {
        guard UIApplication.respondsToSelector(#selector(UIApplication.sharedApplication)) else {
            return nil
        }
        
        guard let unmanagedSharedApplication = UIApplication.performSelector(#selector(UIApplication.sharedApplication)) else {
            return nil
        }
        
        return unmanagedSharedApplication.takeRetainedValue() as? UIApplication
    }
    
}

