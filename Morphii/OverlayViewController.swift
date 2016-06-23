//
//  OverlayViewController.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/8/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit

protocol OverlayViewControllerDelegate {
    
}

class OverlayViewController: UIViewController {
    
    @IBOutlet weak var favoriteMorphiiContainerView: UIView!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var morphiiContainerView: UIView!
    @IBOutlet weak var morphiiContainerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionNameContainerView: UIView!
    @IBOutlet weak var collectionNameLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var morphiiView: MorphiiView!
    var morphiiO:Morphii?
    @IBOutlet weak var morphiiScrollView: MorphiiScrollView!
    @IBOutlet weak var morphiiNameLabel: UILabel!
    var collections = Morphii.getCollectionTitles()
    var favoriteMorphiiView:MorphiiSelectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        containerView.layer.cornerRadius = 8
        containerView.clipsToBounds = true
        checkmarkImageView.image = checkmarkImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
        checkmarkImageView.tintColor = checkmarkImageView.tintColor
        collectionNameContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(OverlayViewController.collectionNameContainerViewTapped(_:))))
    }
    
    func collectionNameContainerViewTapped (tap:UITapGestureRecognizer) {
        morphiiNameLabel.text = "Collections"
        setCenterView(.CollectionTableView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    class func createOverlay<Delegate:UIViewController where Delegate:OverlayViewControllerDelegate> (viewController:Delegate, morphiiO:Morphii?) {
        let nextView = viewController.storyboard?.instantiateViewControllerWithIdentifier(ViewControllerIDs.OverlayViewController) as! OverlayViewController
        viewController.presentViewController(nextView, animated: true, completion: nil)
        nextView.morphiiO = morphiiO
        if let _ = nextView.morphiiO {
            nextView.setMorphii()
        }
    }
    
    func setMorphii() {
        self.morphiiView.setUpMorphii(self.morphiiO!, emoodl: morphiiO!.emoodl?.doubleValue)
        self.morphiiNameLabel.text = self.morphiiO!.name
        if let collectionName = morphiiO?.groupName {
            collectionNameLabel.text = collectionName.uppercaseString
            morphiiScrollView.setMorphiis(Morphii.getMorphiisForCollectionTitle(collectionName), delegate: self)
        }
        print("MORPHII_GROUP:",self.morphiiO!.groupName)
    }
    
    @IBAction func closeButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveMorphiiButtonPressed(sender: UIButton) {
        morphiiView.saveMorphiiToSavedPhotos { (success) in
            if success {
                MethodHelper.showSuccessErrorHUD(true, message: "Saved to Camera Roll", inView: self.view)
            }else {
                print("FAILURE")
            }
        }
    }
    
    
    @IBAction func favoriteMorphiiButtonPressed(sender: UIButton) {
        if let mView = favoriteMorphiiView {
            mView.setNewMorphii(morphiiView.morphii, emoodl: morphiiView.emoodl)
        }else {
            favoriteMorphiiView = MorphiiSelectionView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: favoriteMorphiiContainerView.frame.size), morphii: morphiiView.morphii, delegate: nil)
            favoriteMorphiiContainerView.addSubview(favoriteMorphiiView!)
        }
        setCenterView(.FavoriteView)
    }
    
    @IBAction func shareButtonPressed(sender: UIButton) {
        
        morphiiView.shareMorphii(self)
    }
    
    func setCenterView (containerView:ContainerView) {
        switch containerView {
        case .CollectionTableView:
            morphiiContainerLeadingConstraint.constant = -morphiiContainerView.frame.size.width
            break
        case .FavoriteView:
            morphiiContainerLeadingConstraint.constant = morphiiContainerView.frame.size.width
            break
        case .MorphiiModifyView:
            morphiiContainerLeadingConstraint.constant = 0
            break
        default:
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
