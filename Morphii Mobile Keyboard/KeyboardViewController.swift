//
//  KeyboardViewController.swift
//  Morphii Mobile Keyboard
//
//  Created by netGALAXY Studios on 6/6/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController {

    @IBOutlet var nextKeyboardButton: UIButton!

    override func updateViewConstraints() {
        super.updateViewConstraints()
    
        // Add custom view sizing constraints here
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Perform custom UI setup here
        self.nextKeyboardButton = UIButton(type: .System)
    
        self.nextKeyboardButton.setTitle(NSLocalizedString("Next Keyboard", comment: "Title for 'Next Keyboard' button"), forState: .Normal)
        self.nextKeyboardButton.sizeToFit()
        self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
    
        self.nextKeyboardButton.addTarget(self, action: #selector(advanceToNextInputMode), forControlEvents: .TouchUpInside)
        
        self.view.addSubview(self.nextKeyboardButton)
    
        self.nextKeyboardButton.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor).active = true
        self.nextKeyboardButton.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor).active = true
        
        let coreDataButton = UIButton(type: .System)
        coreDataButton.setTitle("Core Data", forState: .Normal)
        coreDataButton.sizeToFit()
        coreDataButton.translatesAutoresizingMaskIntoConstraints = false
        coreDataButton.addTarget(self, action: #selector(KeyboardViewController.coreDataButtonPressed(_:)), forControlEvents: .TouchUpInside)
        view.addSubview(coreDataButton)
        coreDataButton.widthAnchor.constraintEqualToConstant(coreDataButton.frame.size.width).active = true
        coreDataButton.heightAnchor.constraintEqualToConstant(coreDataButton.frame.size.height).active = true
        coreDataButton.rightAnchor.constraintEqualToAnchor(view.rightAnchor).active = true
        coreDataButton.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
    }
    
    func coreDataButtonPressed (sender:UIButton) {
        //print("PEOPLE:",Person.fetchPeople())

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }

    override func textWillChange(textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }

    override func textDidChange(textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
    
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.Dark {
            textColor = UIColor.whiteColor()
        } else {
            textColor = UIColor.blackColor()
        }
        self.nextKeyboardButton.setTitleColor(textColor, forState: .Normal)
    }

}
