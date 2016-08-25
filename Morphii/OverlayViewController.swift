//
//  OverlayViewController.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/8/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding

protocol OverlayViewControllerDelegate {
    func closedOutOfOverlay ()
}

class OverlayViewController: UIViewController {
    
    @IBOutlet weak var morphiiTouchView: MorphiiTouchView!
    @IBOutlet weak var favoriteContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var morphiiContainerView: UIView!

    @IBOutlet weak var morphiiWideView: MorphiiWideView!
    @IBOutlet weak var tagImageView: UIImageView!
    @IBOutlet weak var favoriteTagsTextField: UITextField!
    @IBOutlet weak var favoriteNameTextField: UITextField!
    @IBOutlet weak var scrollView: TPKeyboardAvoidingScrollView!
    @IBOutlet weak var favoriteMorphiiContainerView: UIView!
    @IBOutlet weak var morphiiContainerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionNameContainerView: UIView!
    @IBOutlet weak var collectionNameLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    var morphiiO:Morphii?
    var delegateO:OverlayViewControllerDelegate?
    @IBOutlet weak var morphiiScrollView: MorphiiScrollView!
    @IBOutlet weak var morphiiNameLabel: UILabel!
    var collections = Morphii.getCollectionTitles()
    var favoriteMorphiiView:MorphiiSelectionView?
    var area:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.scrollEnabled = false
        tagImageView.image = tagImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
        tagImageView.tintColor = tagImageView.tintColor
        // Do any additional setup after loading the view.
        containerView.layer.cornerRadius = 8
        containerView.clipsToBounds = true
        collectionNameContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(OverlayViewController.collectionNameContainerViewTapped(_:))))

        favoriteContainerView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(OverlayViewController.favoriteContainerViewSwiped(_:))))
        //tableView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(OverlayViewController.tableViewSwiped(_:))))
    }
    

    
   override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
      morphiiNameLabel.addTextSpacing(2.5)
   }
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    class func createOverlay<Delegate:UIViewController where Delegate:OverlayViewControllerDelegate> (viewController:Delegate, morphiiO:Morphii?, area:String) {
        let nextView = viewController.storyboard?.instantiateViewControllerWithIdentifier(ViewControllerIDs.OverlayViewController) as! OverlayViewController
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
    
    func setCenterView (containerView:ContainerView) {
        switch containerView {
        case .CollectionTableView:
            morphiiNameLabel.text = "Collections"
            morphiiContainerLeadingConstraint.constant = -morphiiContainerView.frame.size.width
            break
        case .FavoriteView:
            
            morphiiNameLabel.text = "Saved Morphii"
            morphiiContainerLeadingConstraint.constant = morphiiContainerView.frame.size.width
            break
        case .MorphiiModifyView:
            morphiiContainerLeadingConstraint.constant = 0
            break
        }
        UIView.animateWithDuration(0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    enum ContainerView {
        case MorphiiModifyView
        case FavoriteView
        case CollectionTableView
    }
    
}

extension OverlayViewController:MorphiiSelectionViewDelegate {
    func selectedMorphii(morphii: Morphii) {
        self.morphiiO = morphii
        setMorphii()
        var a = ""
        if let ar = area {
            a = ar
        }
        MorphiiAPI.sendMorphiiSelectedToAWS(morphii, area: a)
        setCenterView(.MorphiiModifyView)
    }
}

extension OverlayViewController:UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collections.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIDs.CollectionTableViewCell) as! CollectionTableViewCell
        cell.populateForCollectionTitle(collections[indexPath.row], delegate: self)
        return cell
    }
}

extension OverlayViewController {
    //FavoriteView
    
    @IBAction func addToFavoritesButtonPressed(sender: UIButton) {

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

        favoriteNameTextField.resignFirstResponder()
        favoriteTagsTextField.resignFirstResponder()
      let tags = Morphii.getTagsFromString(favoriteTagsTextField.text)
        if let morphii = Morphii.createNewMorphii(favoriteNameTextField.text, name: favoriteNameTextField.text, scaleType: Int((morphiiO?.scaleType!)!), sequence: Int((morphiiO?.sequence)!), groupName: "Your Saved Morphiis", metaData: morphiiO?.metaData, emoodl: morphiiWideView?.emoodl, isFavorite: true, tags: tags, order: 5000, originalId: morphiiO?.id, originalName: morphiiO?.name, showName: true) {
            
            MethodHelper.showSuccessErrorHUD(true, message: "Saved to Favorites", inView: self.view)
            MorphiiAPI.sendFavoriteData(morphiiO, favoriteNameO: favoriteNameTextField.text, emoodl: favoriteMorphiiView!.morphiiView.emoodl, tags: tags, intensity: morphiiWideView.emoodl)
            print("MORPHIIS_INTENSITY:",morphii.emoodl!.doubleValue)
            MorphiiAPI.sendMorphiiFavoriteSavedToAWS(morphiiO!, intensity: morphii.emoodl!.doubleValue, area: self.area, name: favoriteNameTextField.text!, originalName: morphiiO!.name, tags: tags)
        }else {
            MethodHelper.showAlert("Error", message: "There was an error saving this morphii. Please try again")
        }
    }
    
    func favoriteContainerViewSwiped (pan:UIPanGestureRecognizer) {
        if pan.velocityInView(tableView).x < -800 {
            setCenterView(.MorphiiModifyView)
        }
    }
}

extension OverlayViewController {
    //MorphiiModifyView
    
    func collectionNameContainerViewTapped (tap:UITapGestureRecognizer) {
        setCenterView(.CollectionTableView)
    }
    
    func setMorphii() {
        self.morphiiWideView.setUpMorphii(self.morphiiO!, emoodl: 50.0, morphiiTouchView: self.morphiiTouchView)
        var showName = true
        if let show = morphiiO?.showName?.boolValue {
            showName = show
        }
        if showName {
            self.morphiiNameLabel.text = self.morphiiO!.name
        }else {
            self.morphiiNameLabel.text = ""
        }
        print("SHOWNAME",showName)
        if let collectionName = morphiiO?.groupName {
            collectionNameLabel.text = collectionName
         collectionNameLabel.addTextSpacing(1.6)
            morphiiScrollView.setMorphiis(Morphii.getMorphiisForCollectionTitle(collectionName), delegate: self)
        }
        morphiiWideView.area = self.area
        print("MORPHII_GROUP:",self.morphiiO!.groupName)
    }
    
    @IBAction func saveMorphiiButtonPressed(sender: UIButton) {
        morphiiWideView.saveMorphiiToSavedPhotos { (hasAccess, success) in
            if !hasAccess {
                let alert = UIAlertController(title: "Photo Library Access Required", message: "Access to your photos is required to save Morphiis to your camera roll. Please go to your phone's settings to enable access.", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }else if success {
                MethodHelper.showSuccessErrorHUD(true, message: "Saved to Camera Roll", inView: self.view)
            }else {
                print("FAILURE")
            }
        }
    }
    
    @IBAction func shareButtonPressed(sender: UIButton) {
        morphiiWideView.shareMorphii(self)
    }
    
    @IBAction func favoriteMorphiiButtonPressed(sender: UIButton) {
        favoriteNameTextField.text = ""
        favoriteTagsTextField.text = ""
        if let mView = favoriteMorphiiView {
            mView.setNewMorphii(morphiiWideView.morphii, emoodl: morphiiWideView.emoodl, showName: true)
        }else {
            favoriteMorphiiView = MorphiiSelectionView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: favoriteMorphiiContainerView.frame.size), morphii: morphiiWideView.morphii, delegate: nil, showName: true, useRecentIntensity: false)
            favoriteMorphiiContainerView.addSubview(favoriteMorphiiView!)
            favoriteMorphiiView?.morphiiView.emoodl = morphiiWideView.emoodl
        }
        setCenterView(.FavoriteView)
    }
}

extension OverlayViewController {
    //CollectionTableView
    
    func tableViewSwiped (pan:UIPanGestureRecognizer) {
        if pan.velocityInView(tableView).x > 800 {
            setCenterView(.MorphiiModifyView)
        }
    }
}

extension OverlayViewController:UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string == "" {
            return true
        }
      textField.addTextSpacing(-0.15)
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
            addToFavoritesButtonPressed(UIButton())
        }else {
            favoriteTagsTextField.becomeFirstResponder()
        }
        return true
    }
}

extension UITextField{
   func addTextSpacing(spacing: CGFloat){
      let attributedString = NSMutableAttributedString(string: self.text!)
      attributedString.addAttribute(NSKernAttributeName, value: spacing, range: NSRange(location: 0, length: self.text!.characters.count))
      self.attributedText = attributedString
   }
}
