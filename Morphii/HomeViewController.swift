//
//  HomeViewController.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/7/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var fetchedResultsController:NSFetchedResultsController?
    var fetcher:FetchedDelegateDataSource!
    var collectionO:String?
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    var foundMorphiis = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("CURRENT_USER:",User.getCurrentUser()?.objectID)

        performSelector(#selector(HomeViewController.createFetchedResultsController), withObject: nil, afterDelay: 3)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("VIEWWILLAPPEAR")
        self.createFetchedResultsController()

    }
    
    
    func createFetchedResultsController () {
        let request = NSFetchRequest(entityName: Morphii.EntityName)
        let sort1 = NSSortDescriptor(key: "groupName", ascending: true)
        let sort2 = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sort1, sort2]
        if let collection = collectionO {
            searchButton.hidden = true
            request.predicate = NSPredicate(format: "groupName == %@", collection)
        }else {
            backButton.hidden = true
            request.predicate = NSPredicate(format: "isFavorite != %@", NSNumber(bool: true))
        }
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CDHelper.sharedInstance.managedObjectContext, sectionNameKeyPath: MorphiiAPIKeys.groupName, cacheName: CacheNames.AllMorphiiFetchedResultsCollectionView)
        fetcher = FetchedDelegateDataSource(displayer: self, collectionView: collectionView, fetchedResultsController: fetchedResultsController, allowsReordering: false)

        do {
            try fetchedResultsController?.performFetch()
        }catch {
            
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        MorphiiAPI.checkIfAppIsUpdated { (updated) in
            if !updated {
                ForceUpgradeViewController.createForceUpgradeView(self)
            }
        }
        if !foundMorphiis {
            if collectionO == nil {
                MethodHelper.showHudWithMessage("Checking for updates...", view: view)
            }
            foundMorphiis = true
        }
        performSelector(#selector(HomeViewController.getMorphiis), withObject: nil, afterDelay: 1)
    }
    
    func getMorphiis () {
        print("getMorphiis")
        MorphiiAPI.fetchNewMorphiis { (morphiisArray) in
            MethodHelper.hideHUD()
            self.fetcher.refreshFetchResults()
            self.collectionView.reloadData()
            if !MethodHelper.isReturningUser() {
                TutorialViewController.presenTutorialViewController(self)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func searchButtonPressed(sender: UIButton) {
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier(ViewControllerIDs.SearchViewController) as! SearchViewController
        navigationController?.pushViewController(nextView, animated: true)
        
    }
    @IBAction func backButtonPressed(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }

}

extension HomeViewController:FetchedResultsDisplayer {
    
    func selectedMorphii (morphii:Morphii) {
        MorphiiAPI.sendMorphiiSelectedToAWS(morphii, area: MorphiiAreas.containerHome)
        OverlayViewController.createOverlay(self, morphiiO: morphii, area: MorphiiAreas.containerHome)
    }
    
    func beganRearranging() {
        
    }
}

extension HomeViewController:OverlayViewControllerDelegate {
    func closedOutOfOverlay() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
