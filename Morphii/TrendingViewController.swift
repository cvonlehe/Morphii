//
//  TrendingViewController.swift
//  Morphii
//
//  Created by netGALAXY Studios on 7/12/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit

class TrendingViewcController: UIViewController {
    var newsURL:String?

    @IBOutlet weak var newsTitleLabel: UILabel!
    @IBOutlet weak var newsMessageLabel: UILabel!
    
    @IBOutlet weak var morphiiContainerView1: UIView!
    @IBOutlet weak var morphiiContainerView2: UIView!
    @IBOutlet weak var morphiiContainerView3: UIView!
    @IBOutlet weak var morphiiContainerView4: UIView!
    @IBOutlet weak var morphiiContainerView6: UIView!
    @IBOutlet weak var morphiiContainerView5: UIView!
    @IBOutlet weak var morphiiContainerView7: UIView!
    @IBOutlet weak var morphiiContainerView8: UIView!
    
    @IBOutlet weak var hashtagLabel1: UILabel!
    @IBOutlet weak var hashtagLabel2: UILabel!
    @IBOutlet weak var hashtagLabel3: UILabel!
    @IBOutlet weak var hashtagLabel4: UILabel!
    @IBOutlet weak var hashtagLabel5: UILabel!
    @IBOutlet weak var hashtagLabel6: UILabel!
    @IBOutlet weak var hashtagLabel7: UILabel!
    @IBOutlet weak var hashtagLabel8: UILabel!
    @IBOutlet weak var hashtagLabel9: UILabel!
    @IBOutlet weak var hashtagLabel10: UILabel!
    @IBOutlet weak var hashtagLabel11: UILabel!
    @IBOutlet weak var hashtagLabel12: UILabel!
    @IBOutlet weak var hashtagLabel13: UILabel!
    @IBOutlet weak var hashtagLabel14: UILabel!
    @IBOutlet weak var hashtagLabel15: UILabel!
    
    @IBOutlet weak var trendingHastagContainerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.newsMessageLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TrendingViewcController.newsTapped(_:))))
        self.newsTitleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TrendingViewcController.newsTapped(_:))))
        // Do any additional setup after loading the view.
        //MethodHelper.showHudWithMessage("Loading...", view: view)
        for subview in trendingHastagContainerView.subviews {
            subview.hidden = true
        }
        MorphiiAPI.getTrendingData { (dictO) in
            MethodHelper.hideHUD()
            var trendingDict:NSDictionary?
            if let dict = dictO {
                trendingDict = dict
            }else if let dict = TrendingData.getTrendingData()?.dictionary {
                trendingDict = NSDictionary(dictionary: dict)
            }
            TrendingData.getDataFromDict(trendingDict, completion: { (newsTitle, newsMessage, newsURL, morphiis, hashtags, links) in
                self.setNewsMessageText(newsTitle, text: newsMessage)
                self.newsURL = newsURL
                if let m = morphiis {
                    self.displayMorphiis(m)
                }
                self.displayHashtags(hashtags)
            })
        }

        
    }
    
    func displayHashtags (hashtagsO:[String]?) {
        if let hashtags = hashtagsO {
            print("HASHTAGS_FROM_API:",hashtags)
            for i in 0 ..< hashtags.count {
                var hashtagLabel:UILabel?
                if i == 0 {
                    hashtagLabel = hashtagLabel1
                }else if i == 1 {
                    hashtagLabel = hashtagLabel2
                }else if i == 2 {
                    hashtagLabel = hashtagLabel3
                }else if i == 3 {
                    hashtagLabel = hashtagLabel4
                }else if i == 4 {
                    hashtagLabel = hashtagLabel5
                }else if i == 5 {
                    hashtagLabel = hashtagLabel6
                }else if i == 6 {
                    hashtagLabel = hashtagLabel7
                }else if i == 7 {
                    hashtagLabel = hashtagLabel8
                }else if i == 8 {
                    hashtagLabel = hashtagLabel9
                }else if i == 9 {
                    hashtagLabel = hashtagLabel10
                }else if i == 10 {
                    hashtagLabel = hashtagLabel11
                }else if i == 11 {
                    hashtagLabel = hashtagLabel12
                }else if i == 12 {
                    hashtagLabel = hashtagLabel13
                }else if i == 13 {
                    hashtagLabel = hashtagLabel14
                }else if i == 14 {
                    hashtagLabel = hashtagLabel15
                }
                if let label = hashtagLabel {
                    dispatch_async(dispatch_get_main_queue(), {
                        label.text = "#\(hashtags[i])"
                        label.hidden = false
                        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TrendingViewcController.hashtagLabelTapped(_:))))
                    })
                }
            }
        }
    }
    
    func hashtagLabelTapped (tap:UITapGestureRecognizer) {
        guard let label = tap.view as? UILabel else {return}
        guard let hashtag = label.text else {return}
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier(ViewControllerIDs.SearchViewController) as! SearchViewController
        nextView.hashtag = hashtag
        navigationController?.pushViewController(nextView, animated: true)
    }
    
    func displayMorphiis (morphiis:[Morphii]) {
        for i in 0 ..< morphiis.count {
            let morphii = morphiis[i]
            print("displayMorphiis",i)
            var morphiiContainerView:UIView!
            if i == 0 {
                morphiiContainerView = morphiiContainerView1
            }else if i == 1 {
                morphiiContainerView = morphiiContainerView2
            }else if i == 2 {
                morphiiContainerView = morphiiContainerView3
            }else if i == 3 {
                morphiiContainerView = morphiiContainerView4
            }else if i == 4 {
                morphiiContainerView = morphiiContainerView5
            }else if i == 5 {
                morphiiContainerView = morphiiContainerView6
            }else if i == 6 {
                morphiiContainerView = morphiiContainerView7
            }else {
                morphiiContainerView = morphiiContainerView8
            }
            dispatch_async(dispatch_get_main_queue(), { 
                let morphiiView = MorphiiSelectionView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: morphiiContainerView.frame.size), morphii: morphii, delegate: nil, showName: true)
                morphiiContainerView.addSubview(morphiiView)
                morphiiView.delegate = self
                morphiiView.morphiiView.emoodl = morphii.emoodl!.doubleValue

            })
        }
    }
    
    func newsTapped (tap:UITapGestureRecognizer) {
        if let url = newsURL {
            let nextView = self.storyboard?.instantiateViewControllerWithIdentifier(ViewControllerIDs.SettingsWebViewController) as! SettingsWebViewController
            nextView.loadURL = url
            print("newsTapped",url)
            presentViewController(nextView, animated: true, completion: nil)
        }
    }
    @IBAction func searchButtonPressed(sender: UIButton) {
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier(ViewControllerIDs.SearchViewController) as! SearchViewController
        navigationController?.pushViewController(nextView, animated: true)
    }
    
    private func setNewsMessageText(title:String?, text:String?) {
        dispatch_async(dispatch_get_main_queue()) {
            self.newsTitleLabel.text = title
            self.newsMessageLabel.text = text
            self.newsMessageLabel.preferredMaxLayoutWidth = self.newsMessageLabel.frame.size.width
            self.newsMessageLabel.sizeToFit()
            self.performSelector(#selector(TrendingViewcController.setScrollViewHeight), withObject: nil, afterDelay: 0.5)
        }
    }
    
    func setScrollViewHeight () {
        self.scrollView.contentSize = CGSize(width: UIScreen.mainScreen().bounds.size.width, height: trendingHastagContainerView.frame.origin.y + trendingHastagContainerView.frame.size.height)
        self.scrollView.scrollEnabled = true
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension TrendingViewcController:MorphiiSelectionViewDelegate {
    func selectedMorphii(morphii: Morphii) {
        OverlayViewController.createOverlay(self, morphiiO: morphii)
    }
}

extension TrendingViewcController:OverlayViewControllerDelegate {
    func closedOutOfOverlay() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
