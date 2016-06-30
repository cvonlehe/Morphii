//
//  FetchedDelegateDataSource.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/14/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit
import CoreData
import Foundation

@objc protocol FetchedResultsDisplayer {
    func selectedMorphii (morphii:Morphii)
    func beganRearranging ()
    optional func deletingMorphii (morphii:Morphii)
}



class FetchedDelegateDataSource: NSObject{
    var displayer:FetchedResultsDisplayer!
    var collectionView:UICollectionView!
    var fetchedResultsController:NSFetchedResultsController?
    var allowsReordering = false
    
    init(displayer:FetchedResultsDisplayer, collectionView:UICollectionView, fetchedResultsController:NSFetchedResultsController?, allowsReordering:Bool) {
        super.init()
        self.displayer = displayer
        self.collectionView = collectionView
        self.fetchedResultsController = fetchedResultsController
        collectionView.delegate = self
        collectionView.dataSource = self
        self.allowsReordering = allowsReordering
        if allowsReordering {
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(FetchedDelegateDataSource.handleLongGesture(_:)))
            self.collectionView.addGestureRecognizer(longPressGesture)
        }
    }
    
    func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        
        switch(gesture.state) {
            
        case UIGestureRecognizerState.Began:
            guard let selectedIndexPath = self.collectionView.indexPathForItemAtPoint(gesture.locationInView(self.collectionView)) else {
                break
            }
            for cell in collectionView.visibleCells() {
                let imageView = UIImageView(frame: CGRect(x: 2, y: 2, width: 30, height: 30))
                imageView.image = UIImage(named: "minus")
                imageView.tag = 543
                imageView.userInteractionEnabled = true
                cell.addSubview(imageView)
                imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FetchedDelegateDataSource.minusImageViewTapped(_:))))
            }
            displayer.beganRearranging()
            collectionView.beginInteractiveMovementForItemAtIndexPath(selectedIndexPath)
        case UIGestureRecognizerState.Changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.locationInView(gesture.view!))
        case UIGestureRecognizerState.Ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    func refreshFetchResults () {
        do {
            try fetchedResultsController?.performFetch()
        }catch{
            
        }
    }
    
    func minusImageViewTapped (tap:UITapGestureRecognizer) {
        if let morphii = (tap.view?.superview as? MorphiiCollectionViewCell)?.morphii {
            displayer.deletingMorphii?(morphii)
        }
    }
}

extension FetchedDelegateDataSource:UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections else {return 0}
        let currentSection = sections[section]
        return currentSection.numberOfObjects
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCellIDs.MorphiiCollectionViewCell, forIndexPath: indexPath) as! MorphiiCollectionViewCell
        if let morphii = fetchedResultsController?.objectAtIndexPath(indexPath) as? Morphii {
            cell.populateCellForMorphii(morphii)
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        print("moveItemAtIndexPath")
    }
}

extension FetchedDelegateDataSource:UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let morphii = fetchedResultsController?.objectAtIndexPath(indexPath) as? Morphii {
            self.displayer.selectedMorphii(morphii)
        }
    }
}

extension FetchedDelegateDataSource:UICollectionViewDelegateFlowLayout {
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
    
    
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: CollectionReusableViewIds.HeaderCollectionReusableView, forIndexPath: indexPath) as! HeaderCollectionReusableView
        if let sections = fetchedResultsController?.sections {
            let currentSection = sections[indexPath.section]
            header.titleLabel.text = currentSection.name
        }
        
        return header
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: UIScreen.mainScreen().bounds.size.width, height: CGFloat(30))
    }
}

extension FetchedDelegateDataSource:NSFetchedResultsControllerDelegate {
    
}
