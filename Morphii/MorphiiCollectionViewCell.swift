//
//  MorphiiCollectionViewCell.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/7/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit

class MorphiiCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var morphiiImageView: UIImageView!
    @IBOutlet weak var morphiiNameLabel: UILabel!
    
    func populateCellForMorphii (morphii:Morphii) {
        morphiiNameLabel.text = morphii.name
        morphii.getImage { (imageO) in
            if let image = imageO {
                self.morphiiImageView.image = image
            }
        }
    }
    
    
}
