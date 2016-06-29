//
//  MorphiiTableViewCell.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/28/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit

class MorphiiTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var morphiiView: MorphiiView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }
    
    func populateCellWithMorphii(morphii:Morphii, forCollection:Bool) {
        morphiiView.setUpMorphii(morphii, emoodl: morphii.emoodl?.doubleValue)
        if forCollection {
            if let group = morphii.groupName {
                nameLabel.text = group
            }else {
                nameLabel.text = " "
            }
        }else {
            nameLabel.text = morphii.name
        }
    }

}
