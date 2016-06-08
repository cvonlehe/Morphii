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

class OverlayViewController: UIViewController, MorphiiProtocol {

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
        self.emoodl = 45.0
        setUpMorphiiGestures()
    }
    
    @IBAction func closeButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    var emoodl: Double = 50.0 {
        didSet(newValue){
            newValue
            self.morphiiView.setNeedsDisplay()
        }
    }
    
    func setUpMorphiiGestures(){
        if let _ = self.morphiiView {
            self.morphiiView.dataSource = self
            let panNizer = UIPanGestureRecognizer()
            panNizer.addTarget(self, action: #selector(OverlayViewController.showGestureForPanRecognizer(_:)))
            self.morphiiView.addGestureRecognizer(panNizer)
        }else{
            //fail because self.morphyView is nil
            print("morphy view is nil")
        }
    }
    
    func showGestureForPanRecognizer(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Changed || recognizer.state == UIGestureRecognizerState.Ended {
            let translation:CGPoint = recognizer.translationInView(self.morphiiView)
            if (self.morphiiView.morphii.scaleType == 1){
                //for "positive" emotions use this translation:SCALE TYPE 1
                self.emoodl -= (Double(translation.y)) / 2.5
            } else  if (self.morphiiView.morphii.scaleType == 2){
                //for "positive" emotions use this translation:SCALE TYPE 2
                self.emoodl -= (Double(translation.y)) / 2.5
            } else {
                //for "negative" emotions use this translation:SCALE TYPE 3
                self.emoodl -= (Double(translation.y)) / 2.5
            }
            recognizer.setTranslation(CGPointZero, inView: self.morphiiView)
        }
    }
    
    @IBAction func shareButtonPressed(sender: UIButton) {
        
    }
    
    func smileForMorphiiView(sender:MorphiiView) -> Double{
        return (Double((self.emoodl - 0) / 83))
        
    }



}
