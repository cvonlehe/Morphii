//
//  HomeViewController.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/7/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, OverlayViewControllerDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    var morphiis:[Morphii] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        MorphiiAPI.fetchNewMorphiis { (morphiisArray) in
            self.morphiis = morphiisArray
            self.collectionView.reloadData()
        }

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !MethodHelper.isReturningUser() {
            TutorialViewController.presenTutorialViewController(self)
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
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return morphiis.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCellIDs.MorphiiCollectionViewCell, forIndexPath: indexPath) as! MorphiiCollectionViewCell
        cell.populateCellForMorphii(morphiis[indexPath.row])
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let sideLength = (UIScreen.mainScreen().bounds.size.width / 4)
        return CGSize(width: sideLength - 4, height: sideLength + 30)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let morphii = morphiis[indexPath.row]
        OverlayViewController.createOverlay(self, morphiiO: morphii)
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
