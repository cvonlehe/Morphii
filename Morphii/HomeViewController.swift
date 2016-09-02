//
//  HomeViewController.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/7/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit
import CoreData
import MediaPlayer
import AVKit

class HomeViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var fetchedResultsController:NSFetchedResultsController?
    var fetcher:FetchedDelegateDataSource!
    var collectionO:String?
    var foundMorphiis = false
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("CURRENT_USER:",User.getCurrentUser()?.objectID)
        self.navigationController?.navigationBar.translucent = true
        //shadowHeightConstraint.constant = 0.5
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        button.addTarget(self, action: #selector(HomeViewController.searchButtonPressed(_:)), forControlEvents: .TouchUpInside)
        button.setImage(UIImage(named: "search"), forState: .Normal)
        let barButtonItem = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = barButtonItem

        performSelector(#selector(HomeViewController.createFetchedResultsController), withObject: nil, afterDelay: 2)

    }
    
    func getMorphiisFromJSONFile () {
        guard let path = NSBundle.mainBundle().pathForResource("kb-app-morphiis", ofType: "json") else {return}
        do {
            let string = try String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
            guard let data = string.dataUsingEncoding(NSUTF8StringEncoding) else {return}
            MorphiiAPI.convertJSONToMorphiis(data)
        }catch {
            
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("VIEWWILLAPPEAR")
        self.createFetchedResultsController()
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    func createFetchedResultsController () {
        let request = NSFetchRequest(entityName: Morphii.EntityName)
        let sort1 = NSSortDescriptor(key: "groupName", ascending: true)
        let sort2 = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sort1, sort2]
        if let collection = collectionO {
            request.predicate = NSPredicate(format: "groupName == %@", collection)
        }else {
            //backButton.hidden = true
            request.predicate = NSPredicate(format: "isFavorite != %@", NSNumber(bool: true))
        }
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CDHelper.sharedInstance.managedObjectContext, sectionNameKeyPath: MorphiiAPIKeys.groupName, cacheName: CacheNames.AllMorphiiFetchedResultsCollectionView)
        fetcher = FetchedDelegateDataSource(displayer: self, collectionView: collectionView, fetchedResultsController: fetchedResultsController, allowsReordering: false)
        
        fetchedResultsController?.managedObjectContext.performBlock({ 
            do {
                try self.fetchedResultsController?.performFetch()
            }catch {
                
            }
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !MethodHelper.isReturningUser() {
            getMorphiisFromJSONFile()
            self.displayTutorial()
        }else {
            MorphiiAPI.checkIfAppIsUpdated { (updated) in
                print("viewDidAppear1")
                if !updated {
                    print("viewDidAppear2")
                    let nextView = self.storyboard?.instantiateViewControllerWithIdentifier(ViewControllerIDs.ForceUpgradeViewController) as! ForceUpgradeViewController
                    dispatch_async(dispatch_get_main_queue()) {
                        self.presentViewController(nextView, animated: true, completion: nil)
                    }
                }
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
    
    func presentForceUpgradeView () {
        ForceUpgradeViewController.createForceUpgradeView(self)
    }
    
    func getMorphiis () {
        print("getMorphiis")
        MorphiiAPI.fetchNewMorphiis { (morphiisArray) in
            MethodHelper.hideHUD()
            self.fetcher.refreshFetchResults()
            self.collectionView.reloadData()

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func searchButtonPressed(sender: UIButton) {
        sender.enabled = false
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier(ViewControllerIDs.SearchViewController) as! SearchViewController
        nextView.fromArea = MorphiiAreas.containerHome
        nextView.sender = sender
        navigationController?.pushViewController(nextView, animated: true)
        
        
    }
    @IBAction func backButtonPressed(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func displayTutorial () {
        VideoTutorialViewController.displayVideoTutorialViewController(self)

        
        MorphiiAPI.sendUserProfileActionToAWS(ProfileActions.SetupMorphiiKeyboard)
    }
    
    func playerDidFinishPlaying(note: NSNotification) {
        print("Video Finished")
        dismissViewControllerAnimated(true, completion: nil)
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

