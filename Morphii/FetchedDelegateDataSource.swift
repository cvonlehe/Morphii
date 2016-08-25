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
    var morphiiOrderDict:[Morphii:Int] = [:]
    var longPressGesture:UILongPressGestureRecognizer!
    
    init(displayer:FetchedResultsDisplayer, collectionView:UICollectionView, fetchedResultsController:NSFetchedResultsController?, allowsReordering:Bool) {
        super.init()
        self.displayer = displayer
        self.collectionView = collectionView
        self.fetchedResultsController = fetchedResultsController
        collectionView.delegate = self
        collectionView.dataSource = self
        self.allowsReordering = allowsReordering

    }
    
    func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        print("handleLongGesture")
        switch(gesture.state) {
            
        case UIGestureRecognizerState.Began:
            
            gesture.minimumPressDuration = 0.1
            guard let selectedIndexPath = self.collectionView.indexPathForItemAtPoint(gesture.locationInView(self.collectionView)) else {
                break
            }
            
            for cell in collectionView.visibleCells() {
                for subview in cell.subviews where subview.tag == 543 {
                    subview.removeFromSuperview()
                }
                MethodHelper.wiggle(cell)
                let xImageView = UIImageView(frame: CGRect(x: 2, y: 2, width: 30, height: 30))
                xImageView.image = UIImage(named: "smallx")
                xImageView.alpha = 0.85
                xImageView.backgroundColor = UIColor ( red: 0.8297, green: 0.8297, blue: 0.8297, alpha: 1.0 )
                xImageView.layer.cornerRadius = xImageView.frame.size.width / 2
                xImageView.clipsToBounds = true
                xImageView.tag = 543
                cell.addSubview(xImageView)
                
                let button = UIButton(frame: CGRect(x: 2, y: 2, width: 200, height: 200))
                button.tag = 543
                cell.addSubview(button)
                button.addTarget(self, action: #selector(FetchedDelegateDataSource.minusImageViewTapped(_:)), forControlEvents: .TouchUpInside)
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
    
    func minusImageViewTapped (sender:UIButton) {
        print("minusImageViewTapped")
        if let morphii = (sender.superview as? MorphiiCollectionViewCell)?.morphii {
            displayer.deletingMorphii?(morphii)
        }
    }
    
    func stopEditing () {
        for cell in collectionView.visibleCells() {
            MethodHelper.stopWiggle(cell)
            for subview in cell.subviews where subview.tag == 543 {
                subview.removeFromSuperview()
            }
        }
        longPressGesture.minimumPressDuration = 0.5
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
            print("MORPHII:",morphii.name!,"SCALE:",morphii.scaleType!)
            morphiiOrderDict[morphii] = indexPath.row + indexPath.section
            morphii.order = NSNumber(integer: indexPath.row + indexPath.section)
            CDHelper.sharedInstance.saveContext(nil)
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        guard let cells = collectionView.visibleCells() as? [MorphiiCollectionViewCell] else {return}
        for cell in cells {
            if let morphii = cell.morphii, let indexPath = collectionView.indexPathForCell(cell) {
                morphii.order = NSNumber(integer: indexPath.row + indexPath.section)
            }
        }
        CDHelper.sharedInstance.saveContext(nil)
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
        return CGSize(width: sideLength - 4, height: sideLength + 15)
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
            header.titleLabel.font = UIFont(name: "SFUIDisplay-Light" , size: 15)
         header.titleLabel.addTextSpacing(1.6)
        }
        
        return header
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: UIScreen.mainScreen().bounds.size.width, height: CGFloat(30))
    }
}

extension FetchedDelegateDataSource:NSFetchedResultsControllerDelegate {
    
}
