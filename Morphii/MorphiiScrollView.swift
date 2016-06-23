//
//  MorphiiScrollView.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/23/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit

class MorphiiScrollView: UIScrollView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    func setMorphiis (morphiis:[Morphii], delegate:MorphiiSelectionViewDelegate) {
        for subview in subviews {
            subview.removeFromSuperview()
        }
        var x = CGFloat(0)
        for morphii in morphiis {
            let rect = CGRect(x: x, y: 0, width: frame.size.height, height: frame.size.height)
            addSubview(MorphiiSelectionView(frame: rect, morphii: morphii, delegate: delegate))
            x += frame.size.height
        }
        contentSize = CGSize(width: x, height: frame.size.height)
        scrollEnabled = true
    }

}
