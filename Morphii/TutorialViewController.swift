//
//  TutorialViewController.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/13/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit
import AOTutorial

class TutorialViewController: AOTutorialViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func dismiss(sender: AnyObject!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    class func presenTutorialViewController (viewController:UIViewController) {
        let centerView = TutorialViewController(backgroundImages: ["walkthrough-A.png", "walkthrough-B.png", "walkthrough-C.png"], andInformations:[])
        //        centerView.dismissButton = UIButton(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: 50))
        //        centerView.dismissButton.backgroundColor = UIColor ( red: 0.9869, green: 0.1862, blue: 0.1847, alpha: 1.0 )
        //        centerView.dismissButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        centerView.buttons = UInt(AOTutorialButtonNone)
        centerView.modalPresentationStyle = .OverFullScreen
        viewController.presentViewController(centerView, animated: true, completion: nil)
    }

}
