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
    
    @IBOutlet weak var morphiiView1: MorphiiView!
    @IBOutlet weak var morphiiView2: MorphiiView!
    @IBOutlet weak var morphiiView3: MorphiiView!
    @IBOutlet weak var morphiiView4: MorphiiView!
    @IBOutlet weak var morphiiView5: MorphiiView!
    @IBOutlet weak var morphiiView6: MorphiiView!
    @IBOutlet weak var morphiiView7: MorphiiView!
    @IBOutlet weak var morphiiView8: MorphiiView!
    @IBOutlet weak var trendingHastagContainerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.newsMessageLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TrendingViewcController.newsTapped(_:))))
        self.newsTitleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TrendingViewcController.newsTapped(_:))))
        // Do any additional setup after loading the view.
        MorphiiAPI.getTrendingData { (newsMessage, newsURL, morphiis, hashtags, links) in
            print("MESSAGE:",newsMessage,"URL:",newsURL,"MORPHIIS:",morphiis,"HASHTAGS:",hashtags,"LINKS:",links)
            self.setNewsMessageText(newsMessage)
            self.newsURL = newsURL

            
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
    
    private func setNewsMessageText(text:String?) {
        dispatch_async(dispatch_get_main_queue()) { 
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
