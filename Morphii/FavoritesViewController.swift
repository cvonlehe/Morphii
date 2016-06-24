//
//  FavoritesViewController.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/24/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit
import CoreData

class FavoritesViewController: UIViewController, OverlayViewControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    var fetchedResultsController:NSFetchedResultsController?
    var fetcher:FetchedDelegateDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createFetchedResultsController()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createFetchedResultsController () {
        let request = NSFetchRequest(entityName: Morphii.EntityName)
        let sort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sort]
        request.predicate = NSPredicate(format: "isFavorite == %@", NSNumber(bool: true))
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CDHelper.sharedInstance.managedObjectContext, sectionNameKeyPath: MorphiiAPIKeys.groupName, cacheName: CacheNames.AllMorphiiFetchedResultsCollectionView)
        fetcher = FetchedDelegateDataSource(displayer: self, collectionView: collectionView, fetchedResultsController: fetchedResultsController)
        
        do {
            try fetchedResultsController?.performFetch()
        }catch {
            
        }
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
        OverlayViewController.createOverlay(self, morphiiO: morphii)
    }
}
