//
//  MorphiiCollectionViewCell.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/7/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit

class MorphiiCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var morphiiNameLabel: UIButton!
    @IBOutlet weak var morphiiView: MorphiiView!
    var morphii:Morphii?
    
    func populateCellForMorphii (morphii:Morphii) {
        var shouldShow = true
        if let show = morphii.showName?.boolValue {
            shouldShow = show
        }
        morphiiNameLabel.titleLabel?.numberOfLines = 2
        morphiiNameLabel.titleLabel?.lineBreakMode = .ByWordWrapping
        morphiiNameLabel.titleLabel?.textAlignment = .Center
        morphiiNameLabel.contentHorizontalAlignment = .Center
        morphiiNameLabel.contentVerticalAlignment = .Top
        var name:String? = ""
        if shouldShow {
            name = morphii.name
        }
        UIView.setAnimationsEnabled(false)
        morphiiNameLabel.setTitle(name, forState: .Normal)
        layoutIfNeeded()
        UIView.setAnimationsEnabled(true)

        morphiiView.setUpMorphii(morphii, emoodl: morphii.emoodl?.doubleValue)
        self.morphii = morphii
    }
    
    
}
