//
//  ModifiedMorphiiOverlayViewController.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/30/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit

protocol ModifiedMorphiiOverlayViewControllerDelegate {
    func closedOutOfOverlay ()
}

class ModifiedMorphiiOverlayViewController: UIViewController {
    var morphiiO:Morphii?
    var delegateO:ModifiedMorphiiOverlayViewControllerDelegate?
    @IBOutlet weak var morphiiContainerLeadingConstraint: NSLayoutConstraint!

    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var morphiiContainerView: UIView!
    @IBOutlet weak var favoriteMorphiiView: MorphiiView!
    @IBOutlet weak var morphiiView: MorphiiView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var favoriteTagsTextField: UITextField!
    @IBOutlet weak var favoriteNameTextField: UITextField!
    @IBOutlet weak var morhpiiNameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        containerView.layer.cornerRadius = 8
        containerView.clipsToBounds = true
        morphiiView.userInteractionEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    class func createModifiedMorphiiOverlay<Delegate:UIViewController where Delegate:ModifiedMorphiiOverlayViewControllerDelegate> (viewController:Delegate, morphiiO:Morphii?) {
        let nextView = viewController.storyboard?.instantiateViewControllerWithIdentifier(ViewControllerIDs.ModifiedMorphiiOverlayViewController) as! ModifiedMorphiiOverlayViewController
        viewController.presentViewController(nextView, animated: true, completion: nil)
        nextView.morphiiO = morphiiO
        nextView.delegateO = viewController
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
        
    }
    
    @IBAction func saveButtonPressed(sender: UIButton) {
        morphiiO?.name = morhpiiNameLabel.text
        morphiiO?.tags = NSMutableArray(array: Morphii.getTagsFromString(favoriteTagsTextField.text))
        morphiiO?.emoodl = morphiiView.emoodl
        CDHelper.sharedInstance.saveContext { (success) in
            if success {
                MethodHelper.showSuccessErrorHUD(true, message: "Saved to Favorites", inView: self.view)
            }else {
                MethodHelper.showAlert("Error", message: "There was an error saving your morphii. Please try again")
            }
        }
    }
    
    @IBAction func shareButtonPressed(sender: UIButton) {
        morphiiView.shareMorphii(self)
    }
    
    @IBAction func doneButtonPressed(sender: UIButton) {
        setCenterView(.MorphiiModifyView)
        morhpiiNameLabel.text = favoriteNameTextField.text
        favoriteMorphiiView.emoodl = (morphiiO?.emoodl?.doubleValue)!
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
