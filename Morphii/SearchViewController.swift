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
    var headerHeight:Double = 0
    var morphiiHeaderHeight:Double = 0
    var hashtag:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let _ = hashtag {
            searchLabel.hidden = true
            magnifyingGlassImageView.hidden = true
        }
        // Do any additional setup after loading the view.
        magnifyingGlassImageView.layer.cornerRadius = magnifyingGlassImageView.frame.size.width / 2
        magnifyingGlassImageView.clipsToBounds = true
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 200, right: 0)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let hash = hashtag {
            searchBar.text = hash
            searchForSearchBarText(hash)
        }
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
            if morphiis.count == 0 && searchBar.text != nil && searchBar.text != "" {
                return 1
            }
            return self.morphiis.count
        }else if section == 1  {
            if  searchBar.text != nil && searchBar.text != "" {
                return 1
            }else {
                return 0
            }
        }else {
            if collections.count == 0 && searchBar.text != nil && searchBar.text != "" {
                return 1
            }
            return self.collections.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if morphiis.count == 0 {
                return createNoXTablviewCellWithXValue(tableView, indexPath: indexPath, xValue: "Morphiis")
            }
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIDs.MorphiiTableViewCell, forIndexPath: indexPath) as! MorphiiTableViewCell
            cell.populateCellWithMorphii(morphiis[indexPath.row], forCollection: false)
            return cell
        }else if indexPath.section == 1 {
            if tags.count == 0 {
                return createNoXTablviewCellWithXValue(tableView, indexPath: indexPath, xValue: "Tags")
            }
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIDs.TagsTableViewCell, forIndexPath: indexPath) as! TagsTableViewCell
            cell.populateCellWithTags(tags)
            cell.delegateO = self
            return cell
        }else {
            if collections.count == 0 {
                return createNoXTablviewCellWithXValue(tableView, indexPath: indexPath, xValue: "Collections")
            }
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIDs.MorphiiTableViewCell, forIndexPath: indexPath) as! MorphiiTableViewCell
            cell.populateCellWithMorphii(collections[indexPath.row], forCollection: true)
            return cell
        }
    }
    
    private func createNoXTablviewCellWithXValue (tableView:UITableView, indexPath:NSIndexPath, xValue:String) -> NoXFoundTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIDs.NoXFoundTableViewCell, forIndexPath: indexPath) as! NoXFoundTableViewCell
        cell.titleLabel.text = "No \(xValue) Found"
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 68
        }else if indexPath.section == 1 {
            if rowHeight == 0 {
                return 0
            }else {
                if tags.count == 0 {
                    return 68
                }
                var height:Int = 0
                let rowHeight = 36
                let x:Int = Int(tags.count) / 3
                height = x * rowHeight
                if Int(tags.count) % 3 > 0 {
                    height = height + rowHeight
                }
                return CGFloat(height)
            }
        }else {
            if rowHeight == 0 {
                return 0
            }else if collections.count == 0 {
                return 68
            }
            return CGFloat(rowHeight)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            let morphii = self.morphiis[indexPath.row]
            guard let isFavorite  = morphii.isFavorite?.boolValue else {
                OverlayViewController.createOverlay(self, morphiiO: morphii, area: MorphiiAreas.keyboardSearch)
                return
            }
            if isFavorite {
                ModifiedMorphiiOverlayViewController.createModifiedMorphiiOverlay(self, morphiiO: morphii, area: MorphiiAreas.keyboardSearch)
            }else {
                OverlayViewController.createOverlay(self, morphiiO: morphii, area: MorphiiAreas.keyboardSearch)
            }
        }else if indexPath.section == 2, let cell = tableView.cellForRowAtIndexPath(indexPath) as? MorphiiTableViewCell, let name = cell.nameLabel.text, let nextView = storyboard?.instantiateViewControllerWithIdentifier(ViewControllerIDs.HomeViewController) as?  HomeViewController {
            nextView.collectionO = name
            navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return CGFloat(morphiiHeaderHeight)
        }
        return CGFloat(headerHeight)
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if rowHeight == 0 {
            return UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        }
        let view = UIView(frame: CGRect(x: CGFloat(5), y: CGFloat(0), width: tableView.frame.size.width, height: CGFloat(headerHeight)))
        view.backgroundColor = UIColor ( red: 0.9059, green: 0.9059, blue: 0.9059, alpha: 1.0 )
        let label = UILabel(frame: view.frame)
        label.textColor = UIColor ( red: 0.5225, green: 0.5225, blue: 0.5225, alpha: 1.0 )
        if section == 0 {
            label.text = "Morphiis"
        }else if section == 1 {
            label.text = "Tags"
        }else {
            label.text = "Collections"
        }
        label.font = UIFont(name: "SFUIDisplay-Medium" , size: 17)
        view.addSubview(label)
        return view
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
        if searchText == nil || searchText == "" {
            tags.removeAll()
            collections.removeAll()
            morphiis.removeAll()
            searchLabel.hidden = false
            magnifyingGlassImageView.hidden = false
            tableView.reloadData()
            searchBar.performSelector(#selector(UIResponder.resignFirstResponder), withObject: nil, afterDelay: 0)
            headerHeight = 0
            morphiiHeaderHeight = 0
            return
        }
        morphiiHeaderHeight = 30.0
        if let first = searchText?.characters.first {
            if first == "#" {
                rowHeight = 0
                headerHeight = 0
                if let _ = hashtag {
                    hashtag = nil
                    morphiis = Morphii.getMorphiisForTagMatchingString(searchText)
                }else {
                    morphiis = Morphii.getMorphiisForTagContainingString(searchText)
                }
            }else {
                headerHeight = 30.0
                rowHeight = 68
                morphiis = Morphii.getMorphiisForSearchString(searchText)
            }
        }
        tags.removeAll()
        collections.removeAll()
        collections.appendContentsOf(Morphii.getCollectionsForSearchString(searchText))
        print("SEARCHTEXT:",searchText)
        tags.appendContentsOf(Morphii.getTagsForSearchString(searchBar.text))
        if morphiis.count == 0 && tags.count == 0 && collections.count == 0 && (searchBar.text == nil || searchBar.text == "") {
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

extension SearchViewController:OverlayViewControllerDelegate, ModifiedMorphiiOverlayViewControllerDelegate {
    func closedOutOfOverlay() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
