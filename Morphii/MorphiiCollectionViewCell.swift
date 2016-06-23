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
    
    func populateCellForMorphii (morphii:Morphii) {
        morphiiNameLabel.text = morphii.name
        morphiiView.setUpMorphii(morphii, emoodl: morphii.emoodl?.doubleValue)
    }
    
    
}
