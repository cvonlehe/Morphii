//
//  VideoTutorialViewController.swift
//  Morphii
//
//  Created by netGALAXY Studios on 7/28/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit
import MediaPlayer

class VideoTutorialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let path = NSBundle.mainBundle().pathForResource("allow_full_access", ofType: "mov") else {
            print("NO_PATH")
            return
        }
        let url = NSURL(fileURLWithPath: path)
        let moviePlayer = AVPlayer(URL: url)
        let playerLayer = AVPlayerLayer(player: moviePlayer)
        playerLayer.frame = self.view.bounds
        self.view.layer.addSublayer(playerLayer)
        moviePlayer.play()
        
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
