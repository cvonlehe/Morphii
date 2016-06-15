//
//  OverlayViewController.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/8/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit

protocol OverlayViewControllerDelegate {
    
}

class OverlayViewController: UIViewController {

    @IBOutlet weak var morphiiContainerView: UIView!
    @IBOutlet weak var morphiiContainerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionNameContainerView: UIView!
    @IBOutlet weak var collectionNameLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var morphiiView: MorphiiView!
    var morphiiO:Morphii?
    @IBOutlet weak var morphiiScrollView: UIScrollView!
    @IBOutlet weak var morphiiNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        containerView.layer.cornerRadius = 8
        containerView.clipsToBounds = true
        var x = CGFloat(0)
        for morphii in Morphii.fetchAllMorphiis() {
            let rect = CGRect(x: x, y: 0, width: morphiiScrollView.frame.size.height, height: morphiiScrollView.frame.size.height)
            morphiiScrollView.addSubview(MorphiiSelectionView(frame: rect, morphii: morphii, delegate: self))
            x += morphiiScrollView.frame.size.height
        }
        morphiiScrollView.contentSize = CGSize(width: x, height: morphiiScrollView.frame.size.height)
        morphiiScrollView.scrollEnabled = true
        collectionNameContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(OverlayViewController.collectionNameContainerViewTapped(_:))))
    }
    
    func collectionNameContainerViewTapped (tap:UITapGestureRecognizer) {
        morphiiContainerLeadingConstraint.constant = -morphiiContainerView.frame.size.width
        UIView.animateWithDuration(0.5) {
            self.view.layoutIfNeeded()
        }
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
        if let collectionName = morphiiO?.groupName?.uppercaseString {
            collectionNameLabel.text = collectionName
        }
        print("MORPHII_GROUP:",self.morphiiO!.groupName)
    }
    
    @IBAction func closeButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveMorphiiButtonPressed(sender: UIButton) {
        morphiiView.saveMorphiiToSavedPhotos { (success) in
            if success {
                MethodHelper.showSuccessErrorHUD(true, message: "Saved to Camera Roll", inView: self.view)
            }else {
                print("FAILURE")
            }
        }
    }

    
    @IBAction func favoriteMorphiiButtonPressed(sender: UIButton) {
        
    }

    @IBAction func shareButtonPressed(sender: UIButton) {

        morphiiView.shareMorphii(self)
    }
    
}

extension OverlayViewController:MorphiiSelectionViewDelegate {
    func selectedMorphii(morphii: Morphii) {
        self.morphiiO = morphii
        setMorphii()
    }
}
