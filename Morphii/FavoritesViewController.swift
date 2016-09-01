//
//  FavoritesViewController.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/24/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit
import CoreData

class FavoritesViewController: UIViewController {

    @IBOutlet weak var noFavoritesContainerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    var fetchedResultsController:NSFetchedResultsController?
    var fetcher:FetchedDelegateDataSource!
    var searchButton:UIButton!
    var minDuration = 0.75
    override func viewDidLoad() {
        super.viewDidLoad()
        showSearchButton()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("VIEWWILLAPPEAR")
        self.createFetchedResultsController()
        if fetcher != nil && collectionView != nil {
            if fetcher.longPressGesture != nil {
                fetcher.longPressGesture.minimumPressDuration = minDuration
                self.collectionView.addGestureRecognizer(fetcher.longPressGesture)
            }
        }
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }
   
   override func viewWillDisappear(animated: Bool) {
      super.viewWillDisappear(animated)
      fetcher.stopEditing()
    showSearchButton()
   }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createFetchedResultsController () {
        let request = NSFetchRequest(entityName: Morphii.EntityName)
        let sort = NSSortDescriptor(key: "order", ascending: true)
        request.sortDescriptors = [sort]
        request.predicate = NSPredicate(format: "isFavorite == %@", NSNumber(bool: true))
        if fetcher != nil {
            if fetcher.longPressGesture != nil {
                collectionView.removeGestureRecognizer(fetcher.longPressGesture)
            }
        }
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CDHelper.sharedInstance.managedObjectContext, sectionNameKeyPath: MorphiiAPIKeys.groupName, cacheName: CacheNames.AllMorphiiFetchedResultsCollectionView)
        fetcher = FetchedDelegateDataSource(displayer: self, collectionView: collectionView, fetchedResultsController: fetchedResultsController, allowsReordering: true)
        fetcher.longPressGesture = UILongPressGestureRecognizer(target: fetcher, action: #selector(FetchedDelegateDataSource.handleLongGesture(_:)))
        self.collectionView.addGestureRecognizer(fetcher.longPressGesture)
        do {
            try fetchedResultsController?.performFetch()
            if let objects = fetchedResultsController?.fetchedObjects {
                if objects.count > 0 {
                    noFavoritesContainerView.hidden = true
                    fetcher.longPressGesture.minimumPressDuration = minDuration
                    self.collectionView.addGestureRecognizer(fetcher.longPressGesture)
                }else {
                    noFavoritesContainerView.hidden = false

                }
            }else {
                noFavoritesContainerView.hidden = false
            }
        }catch {
            
        }
    }
    
    @IBAction func doneButtonPressed(sender: UIButton) {
        fetcher.stopEditing()
        showSearchButton()
    }
    
    @IBAction func searchButtonPressed(sender: UIButton) {
        sender.enabled = false

        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier(ViewControllerIDs.SearchViewController) as! SearchViewController
        nextView.fromArea = MorphiiAreas.containerFavorites
        nextView.sender = sender

        navigationController?.pushViewController(nextView, animated: true)

    }
    
    func showDoneButton () {
        
        let dict:[String:AnyObject] = [NSFontAttributeName : UIFont(name: "SFUIText-Regular", size: 17.0)!, NSForegroundColorAttributeName: UIColor ( red: 0.2, green: 0.2235, blue: 0.2902, alpha: 1.0 )]
        let barItem = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(FavoritesViewController.doneButtonPressed(_:)))
        barItem.setTitleTextAttributes(dict, forState: .Normal)
//        searchButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 22))
//        searchButton.addTarget(self, action: #selector(FavoritesViewController.doneButtonPressed(_:)), forControlEvents: .TouchUpInside)
//        searchButton.setTitle("Done", forState: .Normal)
//        searchButton.titleLabel?.textColor = UIColor ( red: 0.2, green: 0.2235, blue: 0.2902, alpha: 1.0 )
//        searchButton.titleLabel?.addTextSpacing(1.6)
//        searchButton.titleLabel?.font = UIFont(name: "SFUIDisplay-Text" , size: 15)
//        let barButtonItem = UIBarButtonItem(customView: searchButton)
        navigationItem.rightBarButtonItem = barItem
    }
    
    func showSearchButton () {
        searchButton = UIButton(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        searchButton.addTarget(self, action: #selector(FavoritesViewController.searchButtonPressed(_:)), forControlEvents: .TouchUpInside)
        searchButton.setImage(UIImage(named: "search"), forState: .Normal)
        searchButton.setTitle(nil, forState: .Normal)
        let barButtonItem = UIBarButtonItem(customView: searchButton)
        navigationItem.rightBarButtonItem = barButtonItem
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

extension FavoritesViewController:FetchedResultsDisplayer {
    
    func selectedMorphii (morphii:Morphii) {
        print("MORPHII_TAGS:",morphii.tags)
        if fetcher.longPressGesture.minimumPressDuration > 0.3 {
            MorphiiAPI.sendMorphiiSelectedToAWS(morphii, area: MorphiiAreas.containerFavorites)
            ModifiedMorphiiOverlayViewController.createModifiedMorphiiOverlay(self, morphiiO: morphii, area: MorphiiAreas.containerFavorites)

        }
    }
    
    func beganRearranging () {
        showDoneButton()
    }
    
    func deletingMorphii(morphii: Morphii) {
        doneButtonPressed(UIButton())
        let alertController = UIAlertController(title: "Delete Morphii?", message: "Are you sure you want to delete this morphii?", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "No", style: .Default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action) in
            morphii.deleteMorphii({ (success) in
                self.createFetchedResultsController()
            })
        }))
        presentViewController(alertController, animated: true, completion: nil)
    }
}

extension FavoritesViewController:ModifiedMorphiiOverlayViewControllerDelegate {
    func closedOutOfOverlay() {
        dismissViewControllerAnimated(true) { 
            self.createFetchedResultsController()

        }
    }
}

