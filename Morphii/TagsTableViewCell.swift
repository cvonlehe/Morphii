//
//  TagsTableViewCell.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/29/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit

protocol TagsTableViewCellDelegate {
    func clickedTag (tag:String)
}

class TagsTableViewCell: UITableViewCell {

    @IBOutlet weak var tagsContainerView: UIView!
    var delegateO:TagsTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func populateCellWithTags (tags:[String]) {
        print("TAGS:",tags)
        for subview in tagsContainerView.subviews {
            subview.removeFromSuperview()
        }
        var x = 4.0
        var y = 4.0
        let width = Double(UIScreen.mainScreen().bounds.size.width / 3) - 8
        let height = 36.0 - 8.0
        
        for tag in tags {
            let tagView = UILabel(frame: CGRect(x: x, y: y, width: width, height: height))
            tagView.text = "#\(tag)"
            tagView.userInteractionEnabled = true
            tagView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TagsTableViewCell.tagViewTapped(_:))))
            tagView.textAlignment = .Center
            tagView.textColor = UIColor.darkGrayColor()
            tagView.backgroundColor = UIColor ( red: 0.8836, green: 0.8836, blue: 0.8836, alpha: 1.0 )
            tagView.font = UIFont(name: "SFUIText-Regular", size: 12.0)
            tagView.layer.cornerRadius = 2
            tagView.layer.masksToBounds = true
            self.tagsContainerView.addSubview(tagView)
            if x + width + 4 + width > Double(UIScreen.mainScreen().bounds.size.width) {
                x = 4
                y = y + height + 8
            }else {
                x = x + width + 8
            }
            
        }
    }
    
    func tagViewTapped (tap:UITapGestureRecognizer) {
        guard let label = tap.view as? UILabel, let tag = label.text, let delegate = delegateO else {return}
        delegate.clickedTag(tag)
        
    }

}

