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

protocol FetchedResultsDisplayer {
    func selectedMorphii (morphii:Morphii)
}



class FetchedDelegateDataSource: NSObject{
    var displayer:FetchedResultsDisplayer!
    var collectionView:UICollectionView!
    var fetchedResultsController:NSFetchedResultsController?
    
    init(displayer:FetchedResultsDisplayer, collectionView:UICollectionView, fetchedResultsController:NSFetchedResultsController?) {
        super.init()
        self.displayer = displayer
        self.collectionView = collectionView
        self.fetchedResultsController = fetchedResultsController
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func refreshFetchResults () {
        do {
            try fetchedResultsController?.performFetch()
        }catch{
            
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
            header.titleLabel.text = currentSection.name.uppercaseString
        }
        
        return header
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: UIScreen.mainScreen().bounds.size.width, height: CGFloat(30))
    }
}

extension FetchedDelegateDataSource:NSFetchedResultsControllerDelegate {
    
}
