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
    var nameLabel:UILabel!
    var morphiiView:MorphiiView!
    
    init(frame:CGRect, morphii:Morphii, delegate:MorphiiSelectionViewDelegate?, showName:Bool) {
        super.init(frame: frame)
        let labelHeight = CGFloat(20)
        let morphiiViewSideLength = CGFloat(frame.size.height - labelHeight - 4)
        morphiiView = MorphiiView(frame: CGRect(x: (frame.size.width / 2) - (morphiiViewSideLength / 2), y: 4, width: morphiiViewSideLength, height: morphiiViewSideLength))
        morphiiView.backgroundColor = UIColor.whiteColor()
        morphiiView.userInteractionEnabled = false
        addSubview(morphiiView)
        nameLabel = UILabel(frame: CGRect(x: 0, y: morphiiView.frame.size.height, width: frame.size.width, height: 30))
        nameLabel.font = UIFont(name: "SFUIText-Regular", size: 12.0)
        nameLabel.textColor = UIColor ( red: 0.2, green: 0.2235, blue: 0.2902, alpha: 1.0 )
        nameLabel.numberOfLines = 2
        nameLabel.lineBreakMode = .ByWordWrapping
        nameLabel.textAlignment = .Center
        addSubview(nameLabel)
        setNewMorphii(morphii, emoodl: morphii.emoodl?.doubleValue, showName: showName)
        backgroundColor = UIColor.whiteColor()
        self.delegate = delegate
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MorphiiSelectionView.viewTapped(_:))))
    }
    
    func setNewMorphii (morphii:Morphii, emoodl:Double?, showName:Bool) {
        print("setNewMorphii")
        var shouldShow = showName
        if let show = morphii.showName?.boolValue {
            shouldShow = show
        }
        if shouldShow {
            nameLabel.text = morphii.name
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
