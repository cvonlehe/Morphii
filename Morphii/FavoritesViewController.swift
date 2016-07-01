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

    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    var fetchedResultsController:NSFetchedResultsController?
    var fetcher:FetchedDelegateDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("VIEWWILLAPPEAR")
        self.createFetchedResultsController()
    }
   
   override func viewWillDisappear(animated: Bool) {
      super.viewWillDisappear(animated)
      fetcher.stopEditing()
      searchButton.hidden = false
      doneButton.hidden = true
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
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CDHelper.sharedInstance.managedObjectContext, sectionNameKeyPath: MorphiiAPIKeys.groupName, cacheName: CacheNames.AllMorphiiFetchedResultsCollectionView)
        fetcher = FetchedDelegateDataSource(displayer: self, collectionView: collectionView, fetchedResultsController: fetchedResultsController, allowsReordering: true)
        
        do {
            try fetchedResultsController?.performFetch()
        }catch {
            
        }
    }
    
    @IBAction func doneButtonPressed(sender: UIButton) {
        fetcher.stopEditing()
        searchButton.hidden = false
        doneButton.hidden = true
    }
    
    @IBAction func searchButtonPressed(sender: UIButton) {
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier(ViewControllerIDs.SearchViewController) as! SearchViewController
        navigationController?.pushViewController(nextView, animated: true)
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
        ModifiedMorphiiOverlayViewController.createModifiedMorphiiOverlay(self, morphiiO: morphii)
    }
    
    func beganRearranging () {
        searchButton.hidden = true
        doneButton.hidden = false
    }
    
    func deletingMorphii(morphii: Morphii) {
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

