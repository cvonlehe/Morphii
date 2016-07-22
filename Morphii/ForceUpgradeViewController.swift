//
//  ForceUpgradeViewController.swift
//  Morphii
//
//  Created by netGALAXY Studios on 7/22/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit

class ForceUpgradeViewController: UIViewController {

    @IBOutlet weak var goToAppStoreButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        goToAppStoreButton.layer.cornerRadius = 4
        goToAppStoreButton.clipsToBounds = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    class func createForceUpgradeView (viewController:UIViewController) {
        let nextView = viewController.storyboard?.instantiateViewControllerWithIdentifier(ViewControllerIDs.ForceUpgradeViewController) as! ForceUpgradeViewController
        dispatch_async(dispatch_get_main_queue()) { 
            viewController.presentViewController(nextView, animated: true, completion: nil)
        }
    }

    @IBAction func goToAppStoreButtonPressed(sender: UIButton) {
        openURLInDefaultBrowser(Config.getCurrentConfig().appStoreUrl)
    }
    
    func openURLInDefaultBrowser (url:String) {
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
    }
}
