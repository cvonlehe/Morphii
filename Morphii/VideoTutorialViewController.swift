//
//  VideoTutorialViewController.swift
//  Morphii
//
//  Created by netGALAXY Studios on 7/28/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit
import MediaPlayer
import EZYGradientView

class VideoTutorialViewController: UIViewController {
    @IBOutlet weak var videoContainer: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var gestureView: UIView!
    var videoIndex = 0
    var moviePlayer:AVPlayer!
    var playerLayer:AVPlayerLayer!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var allowFullAccessLabel: UILabel!
    @IBOutlet weak var gradientContainerViewXConstraint: NSLayoutConstraint!
    var gradientViewAdded = false

    @IBOutlet weak var gradientContainerView1: UIView!
    @IBOutlet weak var descriptionLabel1: UILabel!
    @IBOutlet weak var descriptionLabel2: UILabel!
    @IBOutlet weak var gradientContainerView2: UIView!
    @IBOutlet weak var gradientContainerView3: UIView!
    
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

        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(VideoTutorialViewController.gestureViewSwiped(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.gestureView.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(VideoTutorialViewController.gestureViewSwiped(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.gestureView.addGestureRecognizer(swipeLeft)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !gradientViewAdded {
            gradientViewAdded = true
            createGradientView(gradientContainerView1, color1: UIColor ( red: 0.0431, green: 0.3529, blue: 0.7529, alpha: 1.0 ), color2: UIColor ( red: 0.0784, green: 0.6471, blue: 0.8275, alpha: 1.0 ))
            createGradientView(gradientContainerView2, color1: UIColor ( red: 0.0995, green: 0.5792, blue: 0.7871, alpha: 1.0 ), color2: UIColor ( red: 0.1101, green: 0.7799, blue: 0.7092, alpha: 1.0 ))
            createGradientView(gradientContainerView3, color1: UIColor ( red: 0.1101, green: 0.7799, blue: 0.7092, alpha: 1.0 ), color2: UIColor ( red: 0.1327, green: 1.0, blue: 0.6248, alpha: 1.0 ))

            playerLayer.frame = self.videoContainer.bounds
            self.videoContainer.layer.addSublayer(playerLayer)
            moviePlayer.play()

        }
    }
    
    func createGradientView (containerView:UIView, color1:UIColor, color2:UIColor) {
        let gradientView = EZYGradientView()
        gradientView.frame = CGRect(x: 0, y: 0, width: containerView.frame.size.width, height: containerView.frame.size.height)
        gradientView.firstColor = color1
        gradientView.secondColor = color2
        gradientView.angleº = 90.0
        gradientView.colorRatio = 0.5
        
        gradientView.fadeIntensity = 0.5
        gradientView.isBlur = false
        //gradientView.blurOpacity = 0.5
        
        containerView.addSubview(gradientView)
        
        let widthConstraint = NSLayoutConstraint(item: gradientView, attribute: .Width, relatedBy: .Equal, toItem: containerView, attribute: .Width, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: gradientView, attribute: .Height, relatedBy: .Equal, toItem: containerView, attribute: .Height, multiplier: 1, constant: 0)
        let xConstraint = NSLayoutConstraint(item: gradientView, attribute: .CenterX, relatedBy: .Equal, toItem: containerView, attribute: .CenterX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: gradientView, attribute: .Top, relatedBy: .Equal, toItem: containerView, attribute: .Top, multiplier: 1, constant: 0)
        containerView.addConstraints([widthConstraint, heightConstraint, xConstraint, yConstraint])
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func playerDidFinishPlaying(note: NSNotification) {
        performSelector(#selector(VideoTutorialViewController.handlePlayerFinished), withObject: nil, afterDelay: 3)

    }
    
    func handlePlayerFinished () {
        print("Video Finished")
        if videoIndex == 0 {
            videoIndex = 1
            handleVideoIndex()
        }else if videoIndex == 1 {
            videoIndex = 2
            handleVideoIndex()
        }else {
            pageControl.currentPage = videoIndex
        }
    }
    
    func gestureViewSwiped (gesture:UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            moviePlayer.pause()
            
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
            self.view.layoutIfNeeded()
            UIView.animateWithDuration(0.4) {
                self.gradientContainerViewXConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
            allowFullAccessLabel.hidden = true
            titleLabel.hidden = false
            descriptionLabel1.hidden = false
            descriptionLabel2.hidden = true
            titleLabel.text = "HOW TO MORPHII"
            playVideoWithTitle(VideoTitles.video1)
            
            break
        case 1:
            self.view.layoutIfNeeded()
            UIView.animateWithDuration(0.4) {
                self.gradientContainerViewXConstraint.constant = -(UIScreen.mainScreen().bounds.size.width)
                self.view.layoutIfNeeded()
            }
            allowFullAccessLabel.hidden = true
            titleLabel.hidden = false
            descriptionLabel2.hidden = false
            descriptionLabel1.hidden = true
            titleLabel.text = "HOW TO INSTALL"

            playVideoWithTitle(VideoTitles.video2)
            break
        case 2:
            self.view.layoutIfNeeded()
            UIView.animateWithDuration(0.4) {
                self.gradientContainerViewXConstraint.constant = -(UIScreen.mainScreen().bounds.size.width * 2)
                self.view.layoutIfNeeded()
            }
            titleLabel.hidden = true
            descriptionLabel1.hidden = true
            descriptionLabel2.hidden = true
            allowFullAccessLabel.hidden = false
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
