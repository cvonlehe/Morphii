//
//  AddFavoriteContainerView.swift
//  Morphii
//
//  Created by netGALAXY Studios on 7/21/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit

protocol AddFavoriteContainerViewDelegate {
   func closeButtonPressed()
}

class AddFavoriteContainerView: ExtraView {
   
   @IBOutlet weak var tagsCoverView: UIView!
   @IBOutlet weak var nameCoverView: UIView!
   @IBOutlet weak var tagsTextField: UntouchableTextField!
   @IBOutlet weak var nameTextField: UntouchableTextField!
   @IBOutlet weak var morphiiView: MorphiiView!
   var delegate:AddFavoriteContainerViewDelegate!
   
   
   required init(globalColors: GlobalColors.Type?, darkMode: Bool, solidColorMode: Bool) {
      super.init(globalColors: globalColors, darkMode: darkMode, solidColorMode: solidColorMode)
      self.loadNib()
      addPaddingToTextField(nameTextField)
      addPaddingToTextField(tagsTextField)
      KeyboardViewController.sViewController.keyboard.returnKeyboardKey.lowercaseKeyCap = "Next"
      KeyboardViewController.sViewController.keyboard.returnKeyboardKey.uppercaseKeyCap = "Next"
      KeyboardViewController.returnKeyString = "Next"
      nameCoverView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AddFavoriteContainerView.nameCoverViewTapped(_:))))
      tagsCoverView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AddFavoriteContainerView.tagsCoverViewTapped(_:))))
   }
   
   func nameCoverViewTapped (tap:UITapGestureRecognizer) {
      KeyboardViewController.sViewController.keyboard.returnKeyboardKey.lowercaseKeyCap = "Next"
      KeyboardViewController.sViewController.keyboard.returnKeyboardKey.uppercaseKeyCap = "Next"
      KeyboardViewController.returnKeyString = "Next"
      
      nameTextField.setFieldActive(true)
      tagsTextField.setFieldActive(false)
      
   }
   
   func tagsCoverViewTapped (tap:UITapGestureRecognizer) {
      KeyboardViewController.sViewController.keyboard.returnKeyboardKey.lowercaseKeyCap = "Done"
      KeyboardViewController.sViewController.keyboard.returnKeyboardKey.uppercaseKeyCap = "Done"
      KeyboardViewController.returnKeyString = "Done"
      KeyboardViewController.sViewController.viewDidLayoutSubviews()
      
      nameTextField.setFieldActive(false)
      tagsTextField.setFieldActive(true)
      nameTextField.cursorView?.removeFromSuperview()
   }
   
   
   
   
   func addPaddingToTextField (textField:UITextField) {
      let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 20))
      textField.leftView = paddingView
      textField.leftViewMode = .Always
   }
   
   required init?(coder aDecoder: NSCoder) {
      fatalError("loading from nib not supported")
   }
   
   func loadNib() {
      let assets = NSBundle(forClass: self.dynamicType).loadNibNamed("AddFavoriteContainerView", owner: self, options: nil)
      
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
   
   func addToSuperView(superView:UIView?, morphiiWideView:MorphiiWideView, delegate:AddFavoriteContainerViewDelegate, intensity:Double) {
      print("addMorphiiToFavorites1544:", intensity)
      
      guard let sView = superView else {return}
      sView.addSubview(self)
      translatesAutoresizingMaskIntoConstraints = false
      let widthConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
      let centerXConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
      let top = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
      let bottom = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
      
      sView.addConstraint(widthConstraint)
      sView.addConstraint(top)
      sView.addConstraint(centerXConstraint)
      sView.addConstraint(bottom)
      self.delegate = delegate
      self.morphiiView.setUpMorphii(morphiiWideView.morphii, emoodl: intensity)
      
      morphiiView.userInteractionEnabled = false
      tagsTextField.becomeFirstResponder()
      nameTextField.becomeFirstResponder()
      KeyboardViewController.sViewController.currentMode = 0
   }
   
   @IBAction func closeButtonPressed(sender: UIButton) {
      nameTextField.resignFirstResponder()
      tagsTextField.resignFirstResponder()
      delegate.closeButtonPressed()
   }
   
}

extension UITextField{
   func addTextSpacing(spacing: CGFloat){
      let attributedString = NSMutableAttributedString(string: self.text!)
      attributedString.addAttribute(NSKernAttributeName, value: spacing, range: NSRange(location: 0, length: self.text!.characters.count))
      self.attributedText = attributedString
   }
}
