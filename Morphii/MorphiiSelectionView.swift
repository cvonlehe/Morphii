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
        nameLabel = UILabel(frame: CGRect(x: 0, y: morphiiView.frame.size.height, width: frame.size.width, height: 20))
        nameLabel.font = UIFont(name: nameLabel.font!.fontName, size: 11.0)
        nameLabel.textAlignment = .Center
        addSubview(nameLabel)
        setNewMorphii(morphii, emoodl: morphii.emoodl?.doubleValue, showName: showName)
        backgroundColor = UIColor.whiteColor()
        self.delegate = delegate
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MorphiiSelectionView.viewTapped(_:))))
    }
    
    func setNewMorphii (morphii:Morphii, emoodl:Double?, showName:Bool) {
        if showName {
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
