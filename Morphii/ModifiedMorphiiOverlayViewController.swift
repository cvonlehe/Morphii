//
//  ModifiedMorphiiOverlayViewController.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/30/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding

protocol ModifiedMorphiiOverlayViewControllerDelegate {
    func closedOutOfOverlay ()
}

class ModifiedMorphiiOverlayViewController: UIViewController {
    var morphiiO:Morphii?
    var delegateO:ModifiedMorphiiOverlayViewControllerDelegate?
    @IBOutlet weak var morphiiContainerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagImageView: UIImageView!

    @IBOutlet weak var scrollView: TPKeyboardAvoidingScrollView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var morphiiContainerView: UIView!
    @IBOutlet weak var favoriteMorphiiView: MorphiiView!
    @IBOutlet weak var morphiiView: MorphiiView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var favoriteTagsTextField: UITextField!
    @IBOutlet weak var favoriteNameTextField: UITextField!
    @IBOutlet weak var morhpiiNameLabel: UILabel!
    var area:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.scrollEnabled = false

        // Do any additional setup after loading the view.
        containerView.layer.cornerRadius = 8
        containerView.clipsToBounds = true
        morphiiView.userInteractionEnabled = false
        tagImageView.image = tagImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
        tagImageView.tintColor = tagImageView.tintColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    class func createModifiedMorphiiOverlay<Delegate:UIViewController where Delegate:ModifiedMorphiiOverlayViewControllerDelegate> (viewController:Delegate, morphiiO:Morphii?, area:String) {
        let nextView = viewController.storyboard?.instantiateViewControllerWithIdentifier(ViewControllerIDs.ModifiedMorphiiOverlayViewController) as! ModifiedMorphiiOverlayViewController
        viewController.presentViewController(nextView, animated: true, completion: nil)
        nextView.morphiiO = morphiiO
        nextView.delegateO = viewController
        nextView.area = area
        if let _ = nextView.morphiiO {
            nextView.setMorphii()
        }
    }
    
    @IBAction func closeButtonPressed(sender: UIButton) {
        guard let delegate = delegateO else {return}
        delegate.closedOutOfOverlay()
    }
    
    func setMorphii() {
        self.morphiiView.setUpMorphii(self.morphiiO!, emoodl: morphiiO!.emoodl?.doubleValue)
        morhpiiNameLabel.text = morphiiO?.name
        if let tags = (morphiiO?.tags as? AnyObject) as? [String] {
            var tagsString = tags.joinWithSeparator(" #")
            if tagsString.characters.count > 0 {
                tagsString = "#\(tagsString)"
                favoriteTagsTextField.text = tagsString
            }
        }
        favoriteNameTextField.text = morphiiO?.name
        self.favoriteMorphiiView.setUpMorphii(self.morphiiO!, emoodl: morphiiO!.emoodl?.doubleValue)
        favoriteMorphiiView.area = area

        
    }
    
    @IBAction func saveButtonPressed(sender: UIButton) {

    }
    
    @IBAction func shareButtonPressed(sender: UIButton) {
        morphiiView.shareMorphii(self)
    }
    
    @IBAction func doneButtonPressed(sender: UIButton) {
//        guard let name = favoriteNameTextField.text?.stringByReplacingOccurrencesOfString( " ", withString: "") else {
//            let alertController = UIAlertController(title: "Name Required", message: "A name is required. Please enter a name and try again", preferredStyle: .Alert)
//            alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
//            presentViewController(alertController, animated: true, completion: nil)
//            return
//        }
//        if name == "" {
//            let alertController = UIAlertController(title: "Name Required", message: "A name is required. Please enter a name and try again", preferredStyle: .Alert)
//            alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
//            presentViewController(alertController, animated: true, completion: nil)
//            return
//        }
        setCenterView(.MorphiiModifyView)
        MethodHelper.showSuccessErrorHUD(true, message: "Saved", inView: self.view)
         let tags = Morphii.getTagsFromString(favoriteTagsTextField.text)
        morhpiiNameLabel.text = favoriteNameTextField.text
        morphiiView.emoodl = favoriteMorphiiView.emoodl
        favoriteNameTextField.resignFirstResponder()
        favoriteTagsTextField.resignFirstResponder()
        morphiiO?.name = morhpiiNameLabel.text
        morphiiO?.tags = NSMutableArray(array: tags)
        morphiiO?.emoodl = morphiiView.emoodl
        CDHelper.sharedInstance.saveContext { (success) in
            if success {

                MorphiiAPI.sendFavoriteData(self.morphiiO, favoriteNameO: self.favoriteNameTextField.text, emoodl: self.favoriteMorphiiView.emoodl, tags: tags)
            }else {
                MethodHelper.showAlert("Error", message: "There was an error saving your morphii. Please try again")
            }
        }
    }
    
    @IBAction func editButtonPressed(sender: UIButton) {
        setCenterView(.FavoriteView)
    }
    
    func setCenterView (containerView:ContainerView) {
        switch containerView {
        case .FavoriteView:
            morphiiContainerLeadingConstraint.constant = morphiiContainerView.frame.size.width
            editButton.hidden = true
            break
        case .MorphiiModifyView:
            self.morhpiiNameLabel.text = self.favoriteNameTextField.text
            morphiiContainerLeadingConstraint.constant = 0
            editButton.hidden = false
            break
        }
        UIView.animateWithDuration(0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    enum ContainerView {
        case MorphiiModifyView
        case FavoriteView
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ModifiedMorphiiOverlayViewController:UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string == "" {
            return true
        }
        if favoriteTagsTextField == textField && string == " " {
            guard let wordsArray = favoriteTagsTextField.text?.componentsSeparatedByString(" ") else {return true}
            var newWords:[String] = []
            for var word in wordsArray {
                if let character = word.characters.first where "\(character)" != "#" {
                    word = "#\(word)"
                }
                newWords.append(word)
            }
            favoriteTagsTextField.text = newWords.joinWithSeparator(" ")
            print("WORDS:",newWords)
        }else if textField == favoriteTagsTextField {
            let characterSet = NSCharacterSet(charactersInString: acceptableCharacters)
            let filtered = string.componentsSeparatedByCharactersInSet(characterSet).joinWithSeparator("")
            return string != filtered
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == favoriteTagsTextField {
            textField.resignFirstResponder()
        }else {
            favoriteTagsTextField.becomeFirstResponder()
        }
        return true
    }
}
