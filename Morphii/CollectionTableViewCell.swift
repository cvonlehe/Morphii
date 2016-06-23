//
//  CollectionTableViewCell.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/23/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit

class CollectionTableViewCell: UITableViewCell {

    @IBOutlet weak var morphiiScrollView: MorphiiScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func populateForCollectionTitle (title:String, delegate:MorphiiSelectionViewDelegate) {
        titleLabel.text = title
        let morphiis = Morphii.getMorphiisForCollectionTitle(title)
        morphiiScrollView.setMorphiis(morphiis, delegate: delegate)
    }

}
