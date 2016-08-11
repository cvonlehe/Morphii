//
//  SettingsWebViewController.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/6/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit

class SettingsWebViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var shadowHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var webView: UIWebView!
    var loadURL:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shadowHeightConstraint.constant = 0.5

        // Do any additional setup after loading the view.
        webView.loadRequest(NSURLRequest(URL: NSURL(string: loadURL)!))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    struct URLs {
        static let ourBlog = "http://www.morphii.com/blog"
        static let privacyPolicy = "http://www.morphii.com/privacy-policy"
        static let feedback = "http://support.morphii.com"
        static let termsAndConditions = "http://www.morphii.com/terms-conditions"
    }
    
    @IBAction func doneButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        self.activityIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.activityIndicator.stopAnimating()
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
