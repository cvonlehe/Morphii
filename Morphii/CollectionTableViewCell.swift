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
      titleLabel.textColor = UIColor ( red: 0.2, green: 0.2235, blue: 0.2902, alpha: 1.0 )
      titleLabel.addTextSpacing(1.6)
      titleLabel.font = UIFont(name: "SFUIDisplay-Light" , size: 15)
        let morphiis = Morphii.getMorphiisForCollectionTitle(title)
        morphiiScrollView.setMorphiis(morphiis, delegate: delegate)
    }

}

extension UILabel{
   func addTextSpacing(spacing: CGFloat){
    guard let t = self.text else {return}
      let attributedString = NSMutableAttributedString(string: t)
      attributedString.addAttribute(NSKernAttributeName, value: spacing, range: NSRange(location: 0, length: t.characters.count))
      self.attributedText = attributedString
   }
}
