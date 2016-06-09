//
//  OverlayViewController.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/8/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit
import DynamicBlurView

protocol OverlayViewControllerDelegate {
    
}

class OverlayViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var morphiiView: MorphiiView!
    var morphiiO:Morphii?
    
    @IBOutlet weak var morphiiNameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        containerView.layer.cornerRadius = 8
        containerView.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    class func createOverlay<Delegate:UIViewController where Delegate:OverlayViewControllerDelegate> (viewController:Delegate, morphiiO:Morphii?) {
        let nextView = viewController.storyboard?.instantiateViewControllerWithIdentifier(ViewControllerIDs.OverlayViewController) as! OverlayViewController
        viewController.presentViewController(nextView, animated: true, completion: nil)
        nextView.morphiiO = morphiiO
        if let _ = nextView.morphiiO {
            nextView.setMorphii()
        }
    }
    
    func setMorphii() {
        self.morphiiView.setUpMorphii(self.morphiiO!)
        self.morphiiNameLabel.text = self.morphiiO!.name
    }
    
    @IBAction func closeButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    

    

    

    
    @IBAction func shareButtonPressed(sender: UIButton) {
        morphiiView.shareMorphii(self)
    }
    




}
