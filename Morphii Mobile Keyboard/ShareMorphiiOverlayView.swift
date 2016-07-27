//
//  ShareMorphiiOverlayView.swift
//  Morphii
//
//  Created by netGALAXY Studios on 7/20/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit

protocol ShareMorphiiOverlayViewDelegate {
    func copiedMorphii()
    func cancelPressed()
    func savedMorphiiToCameraRoll()
}

class ShareMorphiiOverlayView: ExtraView {

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var accessRequiredView: UIVisualEffectView!
    @IBOutlet weak var saveToCameraRollContainerView: UIView!
    @IBOutlet weak var addToFavoritesContainerView: UIView!
    @IBOutlet weak var copyMorphiiContainerView: UIView!
    var delegate:ShareMorphiiOverlayViewDelegate!
    var morphiiView:MorphiiView!
    
    required init(globalColors: GlobalColors.Type?, darkMode: Bool, solidColorMode: Bool) {
        super.init(globalColors: globalColors, darkMode: darkMode, solidColorMode: solidColorMode)
        self.loadNib()
        doneButton.layer.cornerRadius = 4
        doneButton.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("loading from nib not supported")
    }
    
    func loadNib() {
        let assets = NSBundle(forClass: self.dynamicType).loadNibNamed("ShareMorphiiOverlayView", owner: self, options: nil)
        
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
                
                copyMorphiiContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ShareMorphiiOverlayView.copyMorphiiContainerViewTapped(_:) as (ShareMorphiiOverlayView) -> (UITapGestureRecognizer) -> ())))
                saveToCameraRollContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ShareMorphiiOverlayView.saveToCameraRollContainerViewTapped(_:))))
                addToFavoritesContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ShareMorphiiOverlayView.addToFavoritesContainerViewTapped(_:))))

            }
        }
        
    }
    
    func copyMorphiiContainerViewTapped (tap:UITapGestureRecognizer) {
        if MethodHelper.openAccessIsGranted() {
            print("GRANTED")
        }else {
            MethodHelper.showSuccessErrorHUD(false, message: "Full Access Required", inView: self)
            return
        }
        superview?.backgroundColor = UIColor.whiteColor()

        if morphiiView.copyMorphyToClipboard() {
            delegate.copiedMorphii()
        }else {
            MethodHelper.showSuccessErrorHUD(false, message: "Error Copying. Try again", inView: self)
        }
    }
    
    func saveToCameraRollContainerViewTapped (tap:UITapGestureRecognizer) {
        morphiiView.saveMorphiiToSavedPhotos { (hasAccess, success) in
            if !hasAccess {
                self.accessRequiredView.hidden = false
            }else if success {
                self.delegate.savedMorphiiToCameraRoll()
            }
        }
    }
    
    func addToFavoritesContainerViewTapped (tap:UITapGestureRecognizer) {
        KeyboardViewController.sViewController.addMorphiiToFavorites(self, morphiiView: morphiiView)
    }
    
    func addToSuperView(superView:UIView?, delegate:ShareMorphiiOverlayViewDelegate, morphiiView:MorphiiView) {
        guard let sView = superView else {return}
        sView.addSubview(self)
        self.delegate = delegate
        translatesAutoresizingMaskIntoConstraints = false
        self.morphiiView = morphiiView
        let widthConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        let centerXConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        
        sView.addConstraint(widthConstraint)
        sView.addConstraint(top)
        sView.addConstraint(centerXConstraint)
        sView.addConstraint(bottom)
        
    }
    @IBAction func cancelButtonPressed(sender: UIButton) {
        delegate.cancelPressed()
    }

    @IBAction func doneButtonPressed(sender: UIButton) {
        accessRequiredView.hidden = true
    }
}
