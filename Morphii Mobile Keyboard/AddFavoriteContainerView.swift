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

    @IBOutlet weak var tagsTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var morphiiView: MorphiiView!
    var delegate:AddFavoriteContainerViewDelegate!

    
    required init(globalColors: GlobalColors.Type?, darkMode: Bool, solidColorMode: Bool) {
        super.init(globalColors: globalColors, darkMode: darkMode, solidColorMode: solidColorMode)
        self.loadNib()
         addPaddingToTextField(nameTextField)
         addPaddingToTextField(tagsTextField)

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
    
    func addToSuperView(superView:UIView?, morphiiView:MorphiiView, delegate:AddFavoriteContainerViewDelegate) {
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
        self.morphiiView.setUpMorphii(morphiiView.morphii, emoodl: morphiiView.emoodl)
        morphiiView.userInteractionEnabled = false
    }

    @IBAction func closeButtonPressed(sender: UIButton) {
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
