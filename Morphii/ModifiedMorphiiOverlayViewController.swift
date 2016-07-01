//
//  ModifiedMorphiiOverlayViewController.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/30/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit

protocol ModifiedMorphiiOverlayViewControllerDelegate {
    func closedOutOfOverlay ()
}

class ModifiedMorphiiOverlayViewController: UIViewController {
    var morphiiO:Morphii?
    var delegateO:ModifiedMorphiiOverlayViewControllerDelegate?
    
    @IBOutlet weak var containerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        containerView.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    class func createModifiedMorphiiOverlay<Delegate:UIViewController where Delegate:ModifiedMorphiiOverlayViewControllerDelegate> (viewController:Delegate, morphiiO:Morphii?) {
        let nextView = viewController.storyboard?.instantiateViewControllerWithIdentifier(ViewControllerIDs.ModifiedMorphiiOverlayViewController) as! ModifiedMorphiiOverlayViewController
        viewController.presentViewController(nextView, animated: true, completion: nil)
        nextView.morphiiO = morphiiO
        nextView.delegateO = viewController
        if let _ = nextView.morphiiO {
            nextView.setMorphii()
        }
    }
    
    @IBAction func closeButtonPressed(sender: UIButton) {
        guard let delegate = delegateO else {return}
        delegate.closedOutOfOverlay()
    }
    
    func setMorphii() {
//        self.morphiiView.setUpMorphii(self.morphiiO!, emoodl: morphiiO!.emoodl?.doubleValue)
//        self.morphiiNameLabel.text = self.morphiiO!.name
//        if let collectionName = morphiiO?.groupName {
//            collectionNameLabel.text = collectionName.uppercaseString
//            morphiiScrollView.setMorphiis(Morphii.getMorphiisForCollectionTitle(collectionName), delegate: self)
//        }
//        print("MORPHII_GROUP:",self.morphiiO!.groupName)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
