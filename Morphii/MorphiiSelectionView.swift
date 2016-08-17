//
//  MorphiiSelectionView.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/14/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit

protocol MorphiiSelectionViewDelegate {
    func selectedMorphii (morphii:Morphii)
}

class MorphiiSelectionView: UIView {
    var morphii:Morphii?
    var delegate:MorphiiSelectionViewDelegate?
    var nameLabel:UIButton!
    var morphiiView:MorphiiView!
    
    init(frame:CGRect, morphii:Morphii, delegate:MorphiiSelectionViewDelegate?, showName:Bool, useRecentIntensity:Bool) {
        super.init(frame: frame)
        let labelHeight = CGFloat(24)
        let morphiiViewSideLength = CGFloat(frame.size.height - labelHeight - 4)
        morphiiView = MorphiiView(frame: CGRect(x: (frame.size.width / 2) - (morphiiViewSideLength / 2), y: 4, width: morphiiViewSideLength, height: morphiiViewSideLength))
        morphiiView.backgroundColor = UIColor.whiteColor()
        morphiiView.userInteractionEnabled = false
        addSubview(morphiiView)
        nameLabel = UIButton(type: .Custom)
        nameLabel.frame = CGRect(x: 0, y: morphiiView.frame.size.height + 4, width: frame.size.width, height: 30)
        nameLabel.titleLabel?.font = UIFont(name: "SFUIText-Regular", size: 12.0)
        nameLabel.setTitleColor(UIColor ( red: 0.3832, green: 0.3832, blue: 0.3832, alpha: 1.0 ), forState: .Normal)
         nameLabel.userInteractionEnabled = false
        nameLabel.titleLabel?.numberOfLines = 2
        nameLabel.titleLabel?.lineBreakMode = .ByWordWrapping
        nameLabel.titleLabel?.textAlignment = .Center
      nameLabel.contentHorizontalAlignment = .Center
      nameLabel.contentVerticalAlignment = .Top
        addSubview(nameLabel)
        var emoodl = morphii.emoodl?.doubleValue
        if useRecentIntensity {
            if let e = morphii.lastUsedIntensity?.doubleValue {
                emoodl = e
            }
        }
        setNewMorphii(morphii, emoodl: emoodl, showName: showName)
        backgroundColor = UIColor.whiteColor()
        self.delegate = delegate
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MorphiiSelectionView.viewTapped(_:))))
    }
    
    func setNewMorphii (morphii:Morphii, emoodl:Double?, showName:Bool) {
        var shouldShow = showName
        if let show = morphii.showName?.boolValue {
            shouldShow = show
        }
        if shouldShow {
            UIView.setAnimationsEnabled(false)
            nameLabel.setTitle(morphii.name, forState: .Normal)
            layoutIfNeeded()
            UIView.setAnimationsEnabled(true)
        }
        morphiiView.setUpMorphii(morphii, emoodl: emoodl)
        self.morphii = morphii
    }
    
    func viewTapped (tap:UITapGestureRecognizer) {
        guard let morphii = morphii, let delegate = delegate else {return}
        delegate.selectedMorphii(morphii)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
