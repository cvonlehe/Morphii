//
//  UntouchableTextField.swift
//  Morphii
//
//  Created by netGALAXY Studios on 8/22/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit

class UntouchableTextField: UITextField {
    var active = false
    var cursorView:UIView?
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    func deleteLastCharacter () {
        guard let t = text else {return}
        guard t.characters.count > 0 else {return}
        let ss1: String = (t as NSString).substringToIndex(t.characters.count - 1)
        text = ss1
    }
    
    func setFieldActive (a:Bool) {
        if a {
            textColor = UIColor.blackColor()
            if cursorView == nil {
                cursorView = UIView(frame: CGRect(x: 0, y: 2, width: 2, height: frame.size.height - 4))
                cursorView?.backgroundColor = UIColor.blueColor()
                addSubview(cursorView!)
                addCursorToTextField(cursorView!)
                resetCursor()
            }
        }else {
            cursorView?.hidden = true
            cursorView?.removeFromSuperview()
            cursorView = nil
        }
        self.active = a

    }
    
    func resetCursor () {
        cursorView?.frame = CGRect(origin: getCursorOrigin(), size: CGSize(width: 2, height: frame.size.height - 4))
        selectedTextRange = textRangeFromPosition(endOfDocument, toPosition: endOfDocument)
        inputView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    }
    
    func getCursorOrigin () -> CGPoint {
        guard let t = text, let font = font else {return CGPoint(x: 0, y: 2)}
        let string = NSString(string: t)
        let width = string.sizeWithAttributes([NSFontAttributeName:font]).width + 4
        return CGPoint(x: width, y: 2)
    }
    
    func addCursorToTextField (textField:UIView) {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = NSNumber(float: 1)
        animation.toValue = NSNumber(float: 0)
        animation.duration = 0.5
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.autoreverses = true
        animation.repeatCount = 20000
        textField.layer.addAnimation(animation, forKey: "opacity")
    }

}
