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
        let sideLength = frame.size.height - 4.0
        for morphii in morphiis {
            let rect = CGRect(x: x, y: 0, width: sideLength, height: sideLength)
            addSubview(MorphiiSelectionView(frame: rect, morphii: morphii, delegate: delegate, showName: true, useRecentIntensity: false))
            x += sideLength
        }
        contentSize = CGSize(width: x, height: 0)
        scrollEnabled = true
    }

}
