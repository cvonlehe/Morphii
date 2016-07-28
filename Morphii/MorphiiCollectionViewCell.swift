//
//  MorphiiCollectionViewCell.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/7/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit

class MorphiiCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var morphiiNameLabel: UILabel!
    @IBOutlet weak var morphiiView: MorphiiView!
    var morphii:Morphii?
    
    func populateCellForMorphii (morphii:Morphii) {
        var shouldShow = true
        if let show = morphii.showName?.boolValue {
            shouldShow = show
        }
        if shouldShow {
            morphiiNameLabel.text = morphii.name
        }else {
            morphiiNameLabel.text = ""

        }
        morphiiView.setUpMorphii(morphii, emoodl: morphii.emoodl?.doubleValue)
        self.morphii = morphii
    }
    
    
}
