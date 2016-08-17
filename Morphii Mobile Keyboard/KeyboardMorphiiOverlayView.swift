//
//  KeyboardMorphiiOverlayView.swift
//  Morphii
//
//  Created by netGALAXY Studios on 7/20/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit

protocol KeyboardMorphiiOverlayViewDelegate {
    func backButtonPressed()
}

class KeyboardMorphiiOverlayView: ExtraView {
    
    @IBOutlet weak var morphiiTouchView: MorphiiTouchView!
    @IBOutlet weak var morphiiNameLabel: UILabel!
    var delegate:KeyboardMorphiiOverlayViewDelegate!
    var shareOverlay:ShareMorphiiOverlayView?

    @IBOutlet weak var morphiiWideView: MorphiiWideView!
    required init(globalColors: GlobalColors.Type?, darkMode: Bool, solidColorMode: Bool) {
        super.init(globalColors: globalColors, darkMode: darkMode, solidColorMode: solidColorMode)
        self.loadNib()
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(KeyboardMorphiiOverlayView.morphiiViewLongPressed(_:)))
        self.morphiiTouchView.addGestureRecognizer(longPressRecognizer)
    }
    
    func morphiiViewLongPressed (press:UILongPressGestureRecognizer) {
        press.enabled = false
        let success = morphiiWideView.copyMorphyToClipboard()
        if success {
            MethodHelper.showSuccessErrorHUD(true, message: "Copied to Clipboard", inView: self)
            morphiiWideView.morphii.lastUsedIntensity = NSNumber(double: morphiiWideView.emoodl)
            CDHelper.sharedInstance.saveContext(nil)
        }else {
            MethodHelper.showSuccessErrorHUD(false, message: "Error Copying to Clipboard", inView: self)
        }
        press.enabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("loading from nib not supported")
    }
    
    func loadNib() {
        let assets = NSBundle(forClass: self.dynamicType).loadNibNamed("KeyboardMorphiiOverlayView", owner: self, options: nil)
        
        if assets.count > 0 {
            if let rootView = assets.first as? UIView {
                rootView.translatesAutoresizingMaskIntoConstraints = false
                self.addSubview(rootView)
                
                let left = NSLayoutConstraint(item: rootView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0)
                let right = NSLayoutConstraint(item: rootView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)
                let top = NSLayoutConstraint(item: rootView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
                let bottom = NSLayoutConstraint(item: rootView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
                
                self.addConstraint(left)
                self.addConstraint(right)
                self.addConstraint(top)
                self.addConstraint(bottom)
            }
        }
        
    }
    
    func addToSuperView<T:UIView where T:KeyboardMorphiiOverlayViewDelegate>(superView:T, morphii:Morphii, area:String) {
        superView.addSubview(self)
        self.delegate = superView
        translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        let centerXConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        
        superView.addConstraint(widthConstraint)
        superView.addConstraint(top)
        superView.addConstraint(centerXConstraint)
        superView.addConstraint(bottom)
        if area == MorphiiAreas.keyboardHome {
            morphiiWideView.setUpMorphii(morphii, emoodl: 50.0, morphiiTouchView: morphiiTouchView)
        }else {
            morphiiWideView.setUpMorphii(morphii, emoodl: morphii.emoodl?.doubleValue, morphiiTouchView: morphiiTouchView)
        }
        var showName = true
        if let show = morphii.showName?.boolValue {
            showName = show
        }
        if showName {
            morphiiNameLabel.text = morphii.name
        }else {
            morphiiNameLabel.text = ""
        }
        morphiiWideView.area = area
        
    }
    
    @IBAction func backButtonPressed(sender: UIButton) {
        delegate.backButtonPressed()
    }
    
    @IBAction func shareButtonPressed(sender: UIButton) {
        if shareOverlay == nil {
            print("AREA3:",morphiiWideView.area)  
            shareOverlay = ShareMorphiiOverlayView(globalColors: globalColors, darkMode: false, solidColorMode: solidColorMode)
            shareOverlay?.addToSuperView(superview?.superview, delegate:self, morphiiView: morphiiWideView, area: self.morphiiWideView.area)
        }
    }

}

extension KeyboardMorphiiOverlayView:ShareMorphiiOverlayViewDelegate {
    func cancelPressed() {
        shareOverlay?.removeFromSuperview()
        shareOverlay = nil
    }
    
    func copiedMorphii() {
        cancelPressed()
        morphiiWideView.backgroundColor = UIColor.clearColor()
        morphiiWideView.morphii.lastUsedIntensity = NSNumber(double: morphiiWideView.emoodl)
        CDHelper.sharedInstance.saveContext(nil)
        MethodHelper.showSuccessErrorHUD(true, message: "Copied to Clipboard", inView: self)
    }
    
    func savedMorphiiToCameraRoll() {
        cancelPressed()
        morphiiWideView.backgroundColor = UIColor.clearColor()
        morphiiWideView.morphii.lastUsedIntensity = NSNumber(double: morphiiWideView.emoodl)
        CDHelper.sharedInstance.saveContext(nil)
        MethodHelper.showSuccessErrorHUD(true, message: "Saved to Camera Roll", inView: self)
    }
    
}
