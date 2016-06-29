//
//  SearchViewController.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/7/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchLabel: UILabel!
    @IBOutlet weak var magnifyingGlassImageView: UIView!
    var morphiis:[Morphii] = []
    var tags:[String] = []
    var collections:[Morphii] = []
    var rowHeight = 68
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        magnifyingGlassImageView.layer.cornerRadius = magnifyingGlassImageView.frame.size.width / 2
        magnifyingGlassImageView.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }

}

extension SearchViewController:UITableViewDelegate,UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.morphiis.count
        }else if section == 1 {
            return 1
        }else {
            return self.collections.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIDs.MorphiiTableViewCell, forIndexPath: indexPath) as! MorphiiTableViewCell
            cell.populateCellWithMorphii(morphiis[indexPath.row], forCollection: false)
            return cell
        }else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIDs.TagsTableViewCell, forIndexPath: indexPath) as! TagsTableViewCell
            cell.populateCellWithTags(tags)
            cell.delegateO = self
            return cell
        }else {
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIDs.MorphiiTableViewCell, forIndexPath: indexPath) as! MorphiiTableViewCell
            cell.populateCellWithMorphii(collections[indexPath.row], forCollection: true)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 || indexPath.section == 2 {
            return CGFloat(rowHeight)
        }else {
            var height:Int = 0
            let rowHeight = 36
            let x:Int = Int(tags.count) / 3
            height = x * rowHeight
            if Int(tags.count) % 3 > 0 {
                height = height + rowHeight
            }
            return CGFloat(height)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            let morphii = self.morphiis[indexPath.row]
            OverlayViewController.createOverlay(self, morphiiO: morphii)
        }
    }
}

extension SearchViewController:UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchForSearchBarText(searchBar.text)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchForSearchBarText (searchText:String?) {
        if let first = searchText?.characters.first {
            if first == "#" {
                rowHeight = 0
            }else {
                rowHeight = 68
            }
        }
        morphiis.removeAll()
        tags.removeAll()
        collections.removeAll()
        morphiis.appendContentsOf(Morphii.getMorphiisForSearchString(searchText))
        collections.appendContentsOf(Morphii.getCollectionsForSearchString(searchText))
        print("SEARCHTEXT:",searchText)
        tags.appendContentsOf(Morphii.getTagsForSearchString(searchBar.text))
        if morphiis.count == 0 && tags.count == 0 && collections.count == 0 {
            searchLabel.hidden = false
            magnifyingGlassImageView.hidden = false
        }else {
            searchLabel.hidden = true
            magnifyingGlassImageView.hidden = true
        }
        
        
        tableView.reloadData()
    }
}

extension SearchViewController:TagsTableViewCellDelegate {
    func clickedTag (tag:String) {
        print("TAG:",tag)
        searchBar.text = tag
        searchForSearchBarText(tag)

    }
}

extension SearchViewController:OverlayViewControllerDelegate {
    
}
