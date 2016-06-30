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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.createFetchedResultsController()
        print("CURRENT_USER:",User.getCurrentUser()?.objectID)

        
    }
    
    
    func createFetchedResultsController () {
        let request = NSFetchRequest(entityName: Morphii.EntityName)
        let sort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sort]
        request.predicate = NSPredicate(format: "isFavorite != %@", NSNumber(bool: true))
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CDHelper.sharedInstance.managedObjectContext, sectionNameKeyPath: MorphiiAPIKeys.groupName, cacheName: CacheNames.AllMorphiiFetchedResultsCollectionView)
        fetcher = FetchedDelegateDataSource(displayer: self, collectionView: collectionView, fetchedResultsController: fetchedResultsController, allowsReordering: false)

        do {
            try fetchedResultsController?.performFetch()
        }catch {
            
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !MethodHelper.isReturningUser() {
            TutorialViewController.presenTutorialViewController(self)
        }else {
            MorphiiAPI.fetchNewMorphiis { (morphiisArray) in
                self.fetcher.refreshFetchResults()
                self.collectionView.reloadData()
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

}

extension HomeViewController:FetchedResultsDisplayer {
    
    func selectedMorphii (morphii:Morphii) {
        OverlayViewController.createOverlay(self, morphiiO: morphii)
    }
    
    func beganRearranging() {
        
    }
}

extension HomeViewController:OverlayViewControllerDelegate {
    func closedOutOfOverlay() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
