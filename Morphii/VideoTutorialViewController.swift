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
    @IBOutlet weak var videoContainer: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var gestureView: UIView!
    var videoIndex = 0
    var moviePlayer:AVPlayer!
    var playerLayer:AVPlayerLayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let path = NSBundle.mainBundle().pathForResource(VideoTitles.video1, ofType: "mov") else {
            print("NO_PATH")
            return
        }
        let url = NSURL(fileURLWithPath: path)
        moviePlayer = AVPlayer(URL: url)
        playerLayer = AVPlayerLayer(player: moviePlayer)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VideoTutorialViewController.playerDidFinishPlaying(_:)),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification, object: moviePlayer.currentItem)
        playerLayer.frame = self.videoContainer.bounds
        self.videoContainer.layer.addSublayer(playerLayer)
        moviePlayer.play()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(VideoTutorialViewController.gestureViewSwiped(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.gestureView.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(VideoTutorialViewController.gestureViewSwiped(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.gestureView.addGestureRecognizer(swipeLeft)
    }
    
    func playerDidFinishPlaying(note: NSNotification) {
        performSelector(#selector(VideoTutorialViewController.handlePlayerFinished), withObject: nil, afterDelay: 3)

    }
    
    func handlePlayerFinished () {
        print("Video Finished")
        if videoIndex == 0 {
            videoIndex = 1
            playVideoWithTitle(VideoTitles.video2)
        }else if videoIndex == 1 {
            videoIndex = 2
            playVideoWithTitle(VideoTitles.video3)
        }
        pageControl.currentPage = videoIndex
    }
    
    func gestureViewSwiped (gesture:UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                print("Swiped right")
                if videoIndex >= 1 {
                    videoIndex -= 1
                    handleVideoIndex()
                }

            case UISwipeGestureRecognizerDirection.Down:
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.Left:
                print("Swiped left")
                if videoIndex <= 1 {
                    videoIndex += 1
                    handleVideoIndex()
                }
            case UISwipeGestureRecognizerDirection.Up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
    func handleVideoIndex () {
        pageControl.currentPage = videoIndex
        switch videoIndex {
        case 0:
            playVideoWithTitle(VideoTitles.video1)
            break
        case 1:
            playVideoWithTitle(VideoTitles.video2)
            break
        case 2:
            playVideoWithTitle(VideoTitles.video3)
            break
        default:
            break
        }
        print("handleVideoIndex:",videoIndex)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    class func displayVideoTutorialViewController (viewController:UIViewController) {
        let nextView = viewController.storyboard?.instantiateViewControllerWithIdentifier(ViewControllerIDs.VideoTutorialViewController) as! VideoTutorialViewController
        viewController.presentViewController(nextView, animated: true, completion: nil)
        MorphiiAPI.sendUserProfileActionToAWS(ProfileActions.SetupMorphiiKeyboard)
    }
    
    func playVideoWithTitle (title:String) {
        guard let path = NSBundle.mainBundle().pathForResource(title, ofType: "mov") else {
            print("NO_PATH")
            return
        }
        let url = NSURL(fileURLWithPath: path)
        moviePlayer.replaceCurrentItemWithPlayerItem(AVPlayerItem(URL: url))
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VideoTutorialViewController.playerDidFinishPlaying(_:)),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification, object: moviePlayer.currentItem)
        moviePlayer.play()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    private class VideoTitles {
        static let video1 = "video1"
        static let video2 = "video2"
        static let video3 = "video3"
    }

}
