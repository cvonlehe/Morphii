//
//  KeyboardViewController.swift
//  Keyboard
//
//

import UIKit
import AudioToolbox

let metrics: [String:Double] = [
    "topBanner": 40
]
func metric(name: String) -> CGFloat { return CGFloat(metrics[name]!) }

// TODO: move this somewhere else and localize
let kAutoCapitalization = "kAutoCapitalization"
let kPeriodShortcut = "kPeriodShortcut"
let kKeyboardClicks = "kKeyboardClicks"
let kSmallLowercase = "kSmallLowercase"

class KeyboardViewController: UIInputViewController {
    static var sViewController:KeyboardViewController!
    static var returnKeyString = "return"
    var globeContainerView:UIView!
    var recentContainerView:UIView!
    var favoriteContainerView:UIView!
    var homeContainerView:UIView!
    var abcContainerView:UIView!
    
    var globeButton:UIButton!
    var recentButton:UIButton!
    var favoriteButton:UIButton!
    var homeButton:UIButton!
    var abcButtonLabel:UILabel!
    var centerView = CenterView.Recents

    var recentView:RecentView?
    
    let backspaceDelay: NSTimeInterval = 0.5
    let backspaceRepeat: NSTimeInterval = 0.07
    
    var keyboard: Keyboard!
    var forwardingView: ForwardingView!
    var layout: KeyboardLayout?
    var heightConstraint: NSLayoutConstraint?
    
    var bannerView: ExtraView?
    var settingsView: ExtraView?
    var addFavoriteContainerView:UIView?
    var shareView:UIView?
    var addFavoriteView:AddFavoriteContainerView?
    var abcDisplayed = true
    var orientation = UIInterfaceOrientation.Portrait
    var coverView:UIView?
    var noAutoCorrectView:UIView?
    
    override func loadView() {
        super.loadView()
        MorphiiAPI.login()
        MorphiiAPI.keyboardActive = true
        MorphiiAPI.getUserDefaults().setBool(true, forKey: kSmallLowercase)

        KeyboardViewController.sViewController = self
        if let aBanner = self.createBanner() {
            aBanner.hidden = true
            self.view.insertSubview(aBanner, belowSubview: self.forwardingView)
            self.bannerView = aBanner
        }
        MorphiiAPI.setupAWS()
        view.backgroundColor = UIColor ( red: 0.9176, green: 0.9333, blue: 0.9451, alpha: 1.0 )
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        coverView = UIView(frame: view.frame)
        coverView?.backgroundColor = UIColor.whiteColor()
        view.addSubview (coverView!)
        let widthConstraint = NSLayoutConstraint(item: coverView!, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: coverView!, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 1, constant: 200)
        let xConstraint = NSLayoutConstraint(item: coverView!, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: coverView!, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0)
        view.addConstraints([widthConstraint, heightConstraint, xConstraint, yConstraint])
        self.bannerView?.hidden = false
        self.keyboardHeight = self.heightForOrientation(self.interfaceOrientation, withTopBanner: true)
        if Morphii.getMostRecentlyUsedMorphiis().count <= 0 {
            setCenterView(.Home)
        }else {
            setCenterView(.Recents)
        }
        

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        performSelector(#selector(KeyboardViewController.addNoAutoCorrectView), withObject: nil, afterDelay: 1)
    }
    
    func addNoAutoCorrectView () {
        let hasSeenAutoCorrect = MorphiiAPI.getUserDefaults().boolForKey("hasSeenAutoCorrect")
        if hasSeenAutoCorrect {
            return
        }
        noAutoCorrectView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        noAutoCorrectView?.backgroundColor = UIColor.whiteColor()
        view.addSubview (noAutoCorrectView!)
        let widthConstraint = NSLayoutConstraint(item: noAutoCorrectView!, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: noAutoCorrectView!, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 1, constant: 0)
        let xConstraint = NSLayoutConstraint(item: noAutoCorrectView!, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: noAutoCorrectView!, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0)
        view.addConstraints([widthConstraint, heightConstraint, xConstraint, yConstraint])
        
        let label = UILabel(frame: CGRect(x: 0, y: 20, width: noAutoCorrectView!.frame.size.width, height: noAutoCorrectView!.frame.size.height - 40))
        label.textAlignment = .Center
        let widthConstraint2 = NSLayoutConstraint(item: label, attribute: .Width, relatedBy: .Equal, toItem: noAutoCorrectView!, attribute: .Width, multiplier: 1, constant: 0)
        let heightConstraint2 = NSLayoutConstraint(item: label, attribute: .Height, relatedBy: .Equal, toItem: noAutoCorrectView!, attribute: .Height, multiplier: 1, constant: -40)
        let xConstraint2 = NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: noAutoCorrectView!, attribute: .CenterX, multiplier: 1, constant: 0)
        let yConstraint2 = NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: noAutoCorrectView!, attribute: .CenterY, multiplier: 1, constant: 0)
        noAutoCorrectView?.addSubview (label)

        view.addConstraints([widthConstraint2, heightConstraint2, xConstraint2, yConstraint2])
        label.numberOfLines = 0
        label.text = "Just so you know, there's no autocorrect in this keyboard"
        
        let noAutocorrectCloseButton = UIButton(frame: CGRect(x: view.frame.size.width - 8 - 20, y: 8, width: 20, height: 20))
        noAutocorrectCloseButton.setImage(UIImage(named: "close_icon"), forState: .Normal)
        let widthConstraint3 = NSLayoutConstraint(item: noAutocorrectCloseButton, attribute: .Width, relatedBy: .Equal, toItem:nil, attribute: .NotAnAttribute, multiplier: 1, constant: 20)
        let heightConstraint3 = NSLayoutConstraint(item: noAutocorrectCloseButton, attribute: .Height, relatedBy: .Equal, toItem:nil, attribute: .NotAnAttribute, multiplier: 1, constant: 20)
        let xConstraint3 = NSLayoutConstraint(item: noAutocorrectCloseButton, attribute: .CenterX, relatedBy: .Equal, toItem: noAutoCorrectView!, attribute: .CenterX, multiplier: 1, constant: 0)
        let yConstraint3 = NSLayoutConstraint(item: noAutocorrectCloseButton, attribute: .CenterY, relatedBy: .Equal, toItem: noAutoCorrectView!, attribute: .CenterY, multiplier: 1, constant: 0)
        noAutoCorrectView?.addSubview (noAutocorrectCloseButton)
        view.addConstraints([widthConstraint3, heightConstraint3, xConstraint3, yConstraint3])
        noAutocorrectCloseButton.addTarget(self, action: #selector(KeyboardViewController.noAutocorrectCloseButtonPressed(_:)), forControlEvents: .TouchUpInside)
    }
    
    func noAutocorrectCloseButtonPressed (sender:UIButton) {
        noAutoCorrectView?.removeFromSuperview()
        noAutoCorrectView = nil
        MorphiiAPI.getUserDefaults().setBool(true, forKey: "hasSeenAutoCorrect")
        MorphiiAPI.getUserDefaults().synchronize()
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        coverView?.hidden = false
        self.forwardingView.resetTrackedViews()
        self.shiftStartingState = nil
        self.shiftWasMultitapped = false
        orientation = toInterfaceOrientation
        // optimization: ensures smooth animation
        if let keyPool = self.layout?.keyPool {
            for view in keyPool {
                view.shouldRasterize = true
            }
        }
        
        self.keyboardHeight = self.heightForOrientation(toInterfaceOrientation, withTopBanner: true)

        
    }
    
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        coverView?.hidden = true
        // optimization: ensures quick mode and shift transitions
        if let keyPool = self.layout?.keyPool {
            for view in keyPool {
                view.shouldRasterize = false
            }
        }
        setCenterView(centerView)
        closeButtonPressed()
        
    }
    
    func addNavigationToBannerView (bannerView:ExtraView) {
        for subview in bannerView.subviews {
            subview.removeFromSuperview()
        }
        let containerWidth = bannerView.frame.size.width / 5
        var containerX = CGFloat(0)
        let buttonLength = CGFloat(20)
        let buttonX = (containerWidth / 2) - (buttonLength / 2)
        let buttonY = (bannerView.frame.size.height / 2) - (buttonLength / 2)
        
        globeContainerView = UIView(frame: CGRect(x: containerX, y: 0, width: containerWidth, height: bannerView.frame.size.height))
        containerX += containerWidth
        bannerView.addSubview(globeContainerView)
        globeButton = UIButton(frame: CGRect(x: buttonX, y: buttonY, width: buttonLength, height: buttonLength))
        globeButton.addTarget(self, action: #selector(KeyboardViewController.globeButtonPressed(_:)), forControlEvents: .TouchUpInside)
        globeContainerView.addSubview(globeButton)
        
        recentContainerView = UIView(frame: CGRect(x: containerX, y: 0, width: containerWidth, height: bannerView.frame.size.height))
        containerX += containerWidth
        bannerView.addSubview(recentContainerView)
        recentButton = UIButton(frame: CGRect(x: buttonX, y: buttonY, width: buttonLength, height: buttonLength))
        recentButton.addTarget(self, action: #selector(KeyboardViewController.recentButtonPressed(_:)), forControlEvents: .TouchUpInside)
        recentContainerView .addSubview(recentButton)
        
        favoriteContainerView = UIView(frame: CGRect(x: containerX, y: 0, width: containerWidth, height: bannerView.frame.size.height))
        containerX += containerWidth
        bannerView.addSubview(favoriteContainerView)
        favoriteButton = UIButton(frame: CGRect(x: buttonX, y: buttonY, width: buttonLength, height: buttonLength))
        favoriteButton.addTarget(self, action: #selector(KeyboardViewController.favoriteButtonPressed(_:)), forControlEvents: .TouchUpInside)
        favoriteContainerView .addSubview(favoriteButton)
        
        homeContainerView = UIView(frame: CGRect(x: containerX, y: 0, width: containerWidth, height: bannerView.frame.size.height))
        containerX += containerWidth
        bannerView.addSubview(homeContainerView)
        homeButton = UIButton(frame: CGRect(x: buttonX, y: buttonY, width: buttonLength, height: buttonLength))
        homeButton.addTarget(self, action: #selector(KeyboardViewController.homeButtonPressed(_:)), forControlEvents: .TouchUpInside)
        homeContainerView.addSubview(homeButton)
        
        
        abcContainerView = UIView(frame: CGRect(x: containerX, y: 0, width: containerWidth, height: bannerView.frame.size.height))
        containerX += containerWidth
        bannerView.addSubview(abcContainerView)
        abcButtonLabel = UILabel(frame: CGRect(x: 0, y: 0, width: abcContainerView.frame.size.width, height: abcContainerView.frame.size.height))
        abcButtonLabel.textAlignment = .Center
        abcButtonLabel.text = "ABC"
        abcButtonLabel.font = UIFont(name: "SFUIText-Regular", size: 15)
      abcButtonLabel.addTextSpacing(0.25)
        abcButtonLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(KeyboardViewController.abcButtonPressed(_:))))
        abcButtonLabel.userInteractionEnabled = true
        abcContainerView.addSubview(abcButtonLabel)
        
        setAllContainerViewBackgrounds()
        
    }
    
    func globeButtonPressed (sender:UIButton) {
        print("globeButtonPressed")
        setCenterView(.Globe)
    }
    
    func recentButtonPressed (sender:UIButton) {
        print("recentButtonPressed")
        setCenterView(.Recents)
        
    }
    
    func favoriteButtonPressed (sender:UIButton) {
        print("favoriteButtonPressed")
        setCenterView(.Favorites)
    } 
    
    func homeButtonPressed (sender:UIButton) {
        print("homeButtonPressed")
        setCenterView(.Home)
    }
    
    func abcButtonPressed (tap:UITapGestureRecognizer) {
        print("abcButtonPressed")
        setCenterView(.Keyboard)
    }
    
    enum CenterView {
        case Globe
        case Recents
        case Favorites
        case Home
        case Keyboard
    }
    
    func setCenterView (center:CenterView) {

        if addFavoriteContainerView != nil {
            return
        }
        centerView = center
        setAllContainerViewBackgrounds()
        recentView?.backButtonPressed()
        performSelector(#selector(KeyboardViewController.displayCenter), withObject: nil, afterDelay: 0.05)
    }
    
    func displayCenter () {
        switch centerView {
        case .Globe:
            self.forwardingView.resetTrackedViews()
            self.shiftStartingState = nil
            self.shiftWasMultitapped = false
            self.advanceToNextInputMode()
            break
        case .Recents:
            setHeight(280)
            setRecentView(.Recents)
            recentView?.titleLabel.addSpacing(1.6)
            break
        case .Favorites:
            setHeight(280)
            setRecentView(.Favorites)
            recentView?.titleLabel.addSpacing(1.6)
            break
        case .Home:
            setHeight(280)
            setRecentView(.Home)
            recentView?.titleLabel.addSpacing(1.6)
            break
        case .Keyboard:
            returnToKeybord()
            break
        }
        coverView?.hidden = true
    }
    
    func setRecentView (fetchType:MorphiiFetchType) {
        if recentView == nil {
            recentView = RecentView(globalColors: self.dynamicType.globalColors, darkMode: false, solidColorMode: self.solidColorMode())
            recentView?.addToSuperView(self.view)
        }
        recentView?.loadMorphiis(fetchType)
    }
    
    func returnToKeybord () {
        if UIInterfaceOrientationIsPortrait(orientation) {
            setHeight(270)
        }else {
            setHeight(210)
        }
        recentView?.removeFromSuperview()
        recentView = nil
    }
    
    func setAllContainerViewBackgrounds () {
        if centerView != .Favorites {
            favoriteContainerView.backgroundColor = UIColor.whiteColor()
            favoriteButton.setImage(UIImage(named: "favorites"), forState: .Normal)
        }else {
            self.favoriteContainerView.backgroundColor = UIColor ( red: 0.0, green: 0.8863, blue: 0.4275, alpha: 1.0 )
            favoriteButton.setImage(UIImage(named: "favorites_selected"), forState: .Normal)
        }
        if centerView != .Globe {
            globeContainerView.backgroundColor = UIColor.whiteColor()
            globeButton.setImage(UIImage(named: "globe"), forState: .Normal)
        }
        if centerView != .Home {
            homeContainerView.backgroundColor = UIColor.whiteColor()
            homeButton.setImage(UIImage(named: "home"), forState: .Normal)
        }else {
            self.homeContainerView.backgroundColor = UIColor ( red: 0.0, green: 0.8863, blue: 0.4275, alpha: 1.0 )
            homeButton.setImage(UIImage(named: "home_selected"), forState: .Normal)
        }
        if centerView != .Keyboard {
            abcContainerView.backgroundColor = UIColor.whiteColor()
            abcButtonLabel.textColor = UIColor ( red: 0.4477, green: 0.4827, blue: 0.5294, alpha: 1.0 )
        }else {
            self.abcContainerView.backgroundColor = UIColor ( red: 0.0, green: 0.8863, blue: 0.4275, alpha: 1.0 )
            abcButtonLabel.textColor = UIColor.whiteColor()
        }
        if centerView != .Recents {
            recentContainerView.backgroundColor = UIColor.whiteColor()
            recentButton.setImage(UIImage(named: "clock"), forState: .Normal)
        }else {
            self.recentContainerView.backgroundColor = UIColor ( red: 0.0, green: 0.8863, blue: 0.4275, alpha: 1.0 )
            recentButton.setImage(UIImage(named: "clock_selected"), forState: .Normal)
        }
    }
    
    var currentMode: Int {
        didSet {
            if oldValue != currentMode {
                setMode(currentMode)
            }
        }
    }
    
    var backspaceActive: Bool {
        get {
            return (backspaceDelayTimer != nil) || (backspaceRepeatTimer != nil)
        }
    }
    
    var backspaceDelayTimer: NSTimer?
    var backspaceRepeatTimer: NSTimer?
    
    enum AutoPeriodState {
        case NoSpace
        case FirstSpace
    }
    
    var autoPeriodState: AutoPeriodState = .NoSpace
    var lastCharCountInBeforeContext: Int = 0
    
    var shiftState: ShiftState {
        didSet {
            switch shiftState {
            case .Disabled:
                self.updateKeyCaps(false)
            case .Enabled:
                self.updateKeyCaps(true)
            case .Locked:
                self.updateKeyCaps(true)
            }
        }
    }
    
    // state tracking during shift tap
    var shiftWasMultitapped: Bool = false
    var shiftStartingState: ShiftState?
    
    var keyboardHeight: CGFloat {
        get {
            if let constraint = self.heightConstraint {
                return constraint.constant
            }
            else {
                return 0
            }
        }
        set {
            self.setHeight(newValue)
        }
    }
    
    // TODO: why does the app crash if this isn't here?
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        MorphiiAPI.getUserDefaults().registerDefaults([
            kAutoCapitalization: true,
            kPeriodShortcut: true,
            kKeyboardClicks: false,
            kSmallLowercase: false
        ])
        
        self.keyboard = defaultKeyboard()
        
        self.shiftState = .Disabled
        self.currentMode = 0
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.forwardingView = ForwardingView(frame: CGRectZero)
        self.view.addSubview(self.forwardingView)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("defaultsChanged:"), name: NSUserDefaultsDidChangeNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    deinit {
        backspaceDelayTimer?.invalidate()
        backspaceRepeatTimer?.invalidate()
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func defaultsChanged(notification: NSNotification) {
        //let defaults = notification.object as? NSUserDefaults
        self.updateKeyCaps(self.shiftState.uppercase())
    }
    
    // without this here kludge, the height constraint for the keyboard does not work for some reason
    var kludge: UIView?
    func setupKludge() {
        if self.kludge == nil {
            let kludge = UIView()
            self.view.addSubview(kludge)
            kludge.translatesAutoresizingMaskIntoConstraints = false
            kludge.hidden = true
            
            let a = NSLayoutConstraint(item: kludge, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0)
            let b = NSLayoutConstraint(item: kludge, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0)
            let c = NSLayoutConstraint(item: kludge, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
            let d = NSLayoutConstraint(item: kludge, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
            self.view.addConstraints([a, b, c, d])
            
            self.kludge = kludge
        }
    }
    
    /*
    BUG NOTE

    For some strange reason, a layout pass of the entire keyboard is triggered 
    whenever a popup shows up, if one of the following is done:

    a) The forwarding view uses an autoresizing mask.
    b) The forwarding view has constraints set anywhere other than init.

    On the other hand, setting (non-autoresizing) constraints or just setting the
    frame in layoutSubviews works perfectly fine.

    I don't really know what to make of this. Am I doing Autolayout wrong, is it
    a bug, or is it expected behavior? Perhaps this has to do with the fact that
    the view's frame is only ever explicitly modified when set directly in layoutSubviews,
    and not implicitly modified by various Autolayout constraints
    (even though it should really not be changing).
    */
    
    var constraintsAdded: Bool = false
    func setupLayout() {
//        constraintsAdded = false
//        for subview in forwardingView.subviews {
//            subview.removeFromSuperview()
//        }
        if !constraintsAdded {
            self.layout = self.dynamicType.layoutClass.init(model: self.keyboard, superview: self.forwardingView, layoutConstants: self.dynamicType.layoutConstants, globalColors: self.dynamicType.globalColors, darkMode: self.darkMode(), solidColorMode: self.solidColorMode())
            
            self.layout?.initialize()
            
            self.setupKludge()
            
            self.updateKeyCaps(self.shiftState.uppercase())
            var capsWasSet = self.setCapsIfNeeded()
            
            self.updateAppearances(self.darkMode())
            self.addInputTraitsObservers()
            
            self.constraintsAdded = true
        }
    }
    
    // only available after frame becomes non-zero
    func darkMode() -> Bool {
//        let darkMode = { () -> Bool in
//            let proxy = self.textDocumentProxy
//            return proxy.keyboardAppearance == UIKeyboardAppearance.Dark
//        }()
//        
//        return darkMode
        return false
    }
    
    func solidColorMode() -> Bool {
        return UIAccessibilityIsReduceTransparencyEnabled()
    }
    
    var lastLayoutBounds: CGRect?
    override func viewDidLayoutSubviews() {
        if view.bounds == CGRectZero {
            return
        }
        
        self.setupLayout()
        
        let orientationSavvyBounds = CGRectMake(0, 0, self.view.bounds.width, self.heightForOrientation(self.interfaceOrientation, withTopBanner: false))
        
        let uppercase = self.shiftState.uppercase()
        let characterUppercase = (MorphiiAPI.getUserDefaults().boolForKey(kSmallLowercase) ? uppercase : true)
        
        self.forwardingView.frame = orientationSavvyBounds
        self.layout?.layoutKeys(self.currentMode, uppercase: uppercase, characterUppercase: characterUppercase, shiftState: self.shiftState)
        self.lastLayoutBounds = orientationSavvyBounds
        self.setupKeys()
        let y = self.view.frame.origin.y + self.view.frame.size.height - metric("topBanner")
        
        self.bannerView?.frame = CGRectMake(0, y, self.view.bounds.width, metric("topBanner"))
        if let banner = bannerView {
            addNavigationToBannerView(banner)
        }
        
        var newOrigin = CGPointMake(0, CGFloat(Int(view.frame.height - metric("topBanner") - orientationSavvyBounds.size.height - 5)))
//        if UIInterfaceOrientationIsPortrait(orientation) {
//            print("returnToKeybord1")
//        }else {
//            print("returnToKeybord2")
//            newOrigin = CGPointMake(0, 0)
//        }
        self.forwardingView.frame.origin = newOrigin
        
    }
    

    

    

    
    func heightForOrientation(orientation: UIInterfaceOrientation, withTopBanner: Bool) -> CGFloat {
        let isPad = UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad
        
        //TODO: hardcoded stuff
        let actualScreenWidth = (UIScreen.mainScreen().nativeBounds.size.width / UIScreen.mainScreen().nativeScale)
        let canonicalPortraitHeight = (isPad ? CGFloat(264) : CGFloat(orientation.isPortrait && actualScreenWidth >= 400 ? 226 : 216))
        let canonicalLandscapeHeight = (isPad ? CGFloat(352) : CGFloat(162))
        let topBannerHeight = (withTopBanner ? metric("topBanner") : 0)
        
        return CGFloat(orientation.isPortrait ? canonicalPortraitHeight + topBannerHeight : canonicalLandscapeHeight + topBannerHeight)
    }
    
    /*
    BUG NOTE

    None of the UIContentContainer methods are called for this controller.
    */
    
    //override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    //    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    //}
    
   func setupKeys() {
      if self.layout == nil {
         return
      }
      
      for page in keyboard.pages {
         for rowKeys in page.rows { // TODO: quick hack
            for key in rowKeys {
               if let keyView = self.layout?.viewForKey(key) {
                  keyView.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.AllEvents)
                  
                  switch key.type {
                  case Key.KeyType.KeyboardChange:
                     keyView.addTarget(self, action: "advanceTapped:", forControlEvents: .TouchUpInside)
                  case Key.KeyType.Backspace:
                     let cancelEvents: UIControlEvents = [UIControlEvents.TouchUpInside, UIControlEvents.TouchUpInside, UIControlEvents.TouchDragExit, UIControlEvents.TouchUpOutside, UIControlEvents.TouchCancel, UIControlEvents.TouchDragOutside]
                     
                     keyView.addTarget(self, action: "backspaceDown:", forControlEvents: .TouchDown)
                     keyView.addTarget(self, action: "backspaceUp:", forControlEvents: cancelEvents)
                  case Key.KeyType.Shift:
                     keyView.addTarget(self, action: Selector("shiftDown:"), forControlEvents: .TouchDown)
                     keyView.addTarget(self, action: Selector("shiftUp:"), forControlEvents: .TouchUpInside)
                     keyView.addTarget(self, action: Selector("shiftDoubleTapped:"), forControlEvents: .TouchDownRepeat)
                  case Key.KeyType.ModeChange:
                     keyView.addTarget(self, action: Selector("modeChangeTapped:"), forControlEvents: .TouchDown)
                  case Key.KeyType.Settings:
                     keyView.addTarget(self, action: Selector("toggleSettings"), forControlEvents: .TouchUpInside)
                  default:
                     break
                  }
                  
                  if key.isCharacter {
                     if UIDevice.currentDevice().userInterfaceIdiom != UIUserInterfaceIdiom.Pad {
                        keyView.addTarget(self, action: Selector("showPopup:"), forControlEvents: [.TouchDown, .TouchDragInside, .TouchDragEnter])
                        keyView.addTarget(keyView, action: Selector("hidePopup"), forControlEvents: [.TouchDragExit, .TouchCancel])
                        keyView.addTarget(self, action: Selector("hidePopupDelay:"), forControlEvents: [.TouchUpInside, .TouchUpOutside, .TouchDragOutside])
                     }
                  }
                  
                  if key.hasOutput {
                     keyView.addTarget(self, action: "keyPressedHelper:", forControlEvents: .TouchUpInside)
                  }
                  
                  if key.type != Key.KeyType.Shift && key.type != Key.KeyType.ModeChange {
                     keyView.addTarget(self, action: Selector("highlightKey:"), forControlEvents: [.TouchDown, .TouchDragInside, .TouchDragEnter])
                     keyView.addTarget(self, action: Selector("unHighlightKey:"), forControlEvents: [.TouchUpInside, .TouchUpOutside, .TouchDragOutside, .TouchDragExit, .TouchCancel])
                  }
                  
                  keyView.addTarget(self, action: Selector("playKeySound"), forControlEvents: .TouchDown)
               }
            }
         }
      }
   }
   
    /////////////////
    // POPUP DELAY //
    /////////////////
   
    var keyWithDelayedPopup: KeyboardKey?
    var popupDelayTimer: NSTimer?
   
    func showPopup(sender: KeyboardKey) {
        if sender == self.keyWithDelayedPopup {
            self.popupDelayTimer?.invalidate()
        }
        sender.showPopup()
    }
    
    func hidePopupDelay(sender: KeyboardKey) {
        self.popupDelayTimer?.invalidate()
        
        if sender != self.keyWithDelayedPopup {
            self.keyWithDelayedPopup?.hidePopup()
            self.keyWithDelayedPopup = sender
        }
        
        if sender.popup != nil {
            self.popupDelayTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: Selector("hidePopupCallback"), userInfo: nil, repeats: false)
        }
    }
    
    func hidePopupCallback() {
        self.keyWithDelayedPopup?.hidePopup()
        self.keyWithDelayedPopup = nil
        self.popupDelayTimer = nil
    }
    
    /////////////////////
    // POPUP DELAY END //
    /////////////////////
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }

    // TODO: this is currently not working as intended; only called when selection changed -- iOS bug
    override func textDidChange(textInput: UITextInput?) {
        self.contextChanged()
    }
    
    func contextChanged() {
        self.setCapsIfNeeded()
        self.autoPeriodState = .NoSpace
    }
    
    func setHeight(height: CGFloat) {
        if self.heightConstraint == nil {
            self.heightConstraint = NSLayoutConstraint(
                item:self.view,
                attribute:NSLayoutAttribute.Height,
                relatedBy:NSLayoutRelation.Equal,
                toItem:nil,
                attribute:NSLayoutAttribute.NotAnAttribute,
                multiplier:0,
                constant:height)
            self.heightConstraint!.priority = 1000
            
            self.view.addConstraint(self.heightConstraint!) // TODO: what if view already has constraint added?
        }
        else {
            self.heightConstraint?.constant = height
        }
    }
    
    func updateAppearances(appearanceIsDark: Bool) {
        self.layout?.solidColorMode = self.solidColorMode()
        self.layout?.darkMode = appearanceIsDark
        self.layout?.updateKeyAppearance()
        
        self.bannerView?.darkMode = appearanceIsDark
        self.settingsView?.darkMode = appearanceIsDark
    }
    
    func highlightKey(sender: KeyboardKey) {
        sender.highlighted = true
    }
    
    func unHighlightKey(sender: KeyboardKey) {
        sender.highlighted = false
    }
    
    func keyPressedHelper(sender: KeyboardKey) {
        print("keyPressedHelper1:",self.layout)
        if self.layout == nil {
            self.layout = self.dynamicType.layoutClass.init(model: self.keyboard, superview: self.forwardingView, layoutConstants: self.dynamicType.layoutConstants, globalColors: self.dynamicType.globalColors, darkMode: self.darkMode(), solidColorMode: self.solidColorMode())
        }
        if let model = self.layout?.keyForView(sender) {
            print("keyPressedHelper2")
            self.keyPressed(model)

            // auto exit from special char subkeyboard
            if model.type == Key.KeyType.Space || model.type == Key.KeyType.Return {
                self.currentMode = 0
            }
            else if model.lowercaseOutput == "'" {
                self.currentMode = 0
            }
            else if model.type == Key.KeyType.Character {
                self.currentMode = 0
            }
            
            // auto period on double space
            // TODO: timeout
            
            self.handleAutoPeriod(model)
            // TODO: reset context
        }
        
        self.setCapsIfNeeded()
    }
    
    func handleAutoPeriod(key: Key) {
        if !MorphiiAPI.getUserDefaults().boolForKey(kPeriodShortcut) {
            return
        }
        
        if self.autoPeriodState == .FirstSpace {
            if key.type != Key.KeyType.Space {
                self.autoPeriodState = .NoSpace
                return
            }
            
            let charactersAreInCorrectState = { () -> Bool in
                let previousContext = self.textDocumentProxy.documentContextBeforeInput
                
                if previousContext == nil || (previousContext!).characters.count < 3 {
                    return false
                }
                
                var index = previousContext!.endIndex
                
                index = index.predecessor()
                if previousContext![index] != " " {
                    return false
                }
                
                index = index.predecessor()
                if previousContext![index] != " " {
                    return false
                }
                
                index = index.predecessor()
                let char = previousContext![index]
                if self.characterIsWhitespace(char) || self.characterIsPunctuation(char) || char == "," {
                    return false
                }
                
                return true
            }()
            
            if charactersAreInCorrectState {
                self.textDocumentProxy.deleteBackward()
                self.textDocumentProxy.deleteBackward()
                self.textDocumentProxy.insertText(".")
                self.textDocumentProxy.insertText(" ")
            }
            
            self.autoPeriodState = .NoSpace
        }
        else {
            if key.type == Key.KeyType.Space {
                self.autoPeriodState = .FirstSpace
            }
        }
    }
    
    func cancelBackspaceTimers() {
        self.backspaceDelayTimer?.invalidate()
        self.backspaceRepeatTimer?.invalidate()
        self.backspaceDelayTimer = nil
        self.backspaceRepeatTimer = nil
    }
    
    func backspaceDown(sender: KeyboardKey) {
        self.cancelBackspaceTimers()
        
        self.textDocumentProxy.deleteBackward()
        self.setCapsIfNeeded()
        
        // trigger for subsequent deletes
        self.backspaceDelayTimer = NSTimer.scheduledTimerWithTimeInterval(backspaceDelay - backspaceRepeat, target: self, selector: Selector("backspaceDelayCallback"), userInfo: nil, repeats: false)
    }
    
    func backspaceUp(sender: KeyboardKey) {
        self.cancelBackspaceTimers()
    }
    
    func backspaceDelayCallback() {
        self.backspaceDelayTimer = nil
        self.backspaceRepeatTimer = NSTimer.scheduledTimerWithTimeInterval(backspaceRepeat, target: self, selector: Selector("backspaceRepeatCallback"), userInfo: nil, repeats: true)
    }
    
    func backspaceRepeatCallback() {
        self.playKeySound()
        
        self.textDocumentProxy.deleteBackward()
        self.setCapsIfNeeded()
    }
    
    func shiftDown(sender: KeyboardKey) {
        self.shiftStartingState = self.shiftState
        
        if let shiftStartingState = self.shiftStartingState {
            if shiftStartingState.uppercase() {
                // handled by shiftUp
                return
            }
            else {
                switch self.shiftState {
                case .Disabled:
                    self.shiftState = .Enabled
                case .Enabled:
                    self.shiftState = .Disabled
                case .Locked:
                    self.shiftState = .Disabled
                }
                
                (sender.shape as? ShiftShape)?.withLock = false
            }
        }
    }
    
    func shiftUp(sender: KeyboardKey) {
        if self.shiftWasMultitapped {
            // do nothing
        }
        else {
            if let shiftStartingState = self.shiftStartingState {
                if !shiftStartingState.uppercase() {
                    // handled by shiftDown
                }
                else {
                    switch self.shiftState {
                    case .Disabled:
                        self.shiftState = .Enabled
                    case .Enabled:
                        self.shiftState = .Disabled
                    case .Locked:
                        self.shiftState = .Disabled
                    }
                    
                    (sender.shape as? ShiftShape)?.withLock = false
                }
            }
        }

        self.shiftStartingState = nil
        self.shiftWasMultitapped = false
    }
    
    func shiftDoubleTapped(sender: KeyboardKey) {
        self.shiftWasMultitapped = true
        
        switch self.shiftState {
        case .Disabled:
            self.shiftState = .Locked
        case .Enabled:
            self.shiftState = .Locked
        case .Locked:
            self.shiftState = .Disabled
        }
    }
    
    func updateKeyCaps(uppercase: Bool) {
        let characterUppercase = (MorphiiAPI.getUserDefaults().boolForKey(kSmallLowercase) ? uppercase : true)
        self.layout?.updateKeyCaps(false, uppercase: uppercase, characterUppercase: characterUppercase, shiftState: self.shiftState)
    }
    
    func modeChangeTapped(sender: KeyboardKey) {
        if let toMode = self.layout?.viewToModel[sender]?.toMode {
            self.currentMode = toMode
        }
    }
    
    func setMode(mode: Int) {
        print("setMode")
        self.forwardingView.resetTrackedViews()
        self.shiftStartingState = nil
        self.shiftWasMultitapped = false
        
        let uppercase = self.shiftState.uppercase()
        let characterUppercase = (MorphiiAPI.getUserDefaults().boolForKey(kSmallLowercase) ? uppercase : true)
        self.layout?.layoutKeys(mode, uppercase: uppercase, characterUppercase: characterUppercase, shiftState: self.shiftState)
        
        self.setupKeys()
    }
    
    func advanceTapped(sender: KeyboardKey) {
        setCenterView(.Home)
    }
    
    @IBAction func toggleSettings() {
//        // lazy load settings
//        if self.settingsView == nil {
//            if let aSettings = self.createSettings() {
//                aSettings.darkMode = self.darkMode()
//                
//                aSettings.hidden = true
//                self.view.addSubview(aSettings)
//                self.settingsView = aSettings
//                
//                aSettings.translatesAutoresizingMaskIntoConstraints = false
//                
//                let widthConstraint = NSLayoutConstraint(item: aSettings, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
//                let heightConstraint = NSLayoutConstraint(item: aSettings, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
//                let centerXConstraint = NSLayoutConstraint(item: aSettings, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
//                let centerYConstraint = NSLayoutConstraint(item: aSettings, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
//                
//                self.view.addConstraint(widthConstraint)
//                self.view.addConstraint(heightConstraint)
//                self.view.addConstraint(centerXConstraint)
//                self.view.addConstraint(centerYConstraint)
//            }
//        }
//        
//        if let settings = self.settingsView {
//            let hidden = settings.hidden
//            settings.hidden = !hidden
//            self.forwardingView.hidden = hidden
//            self.forwardingView.userInteractionEnabled = !hidden
//            self.bannerView?.hidden = hidden
//        }
    }
    
    func setCapsIfNeeded() -> Bool {
        if self.shouldAutoCapitalize() {
            switch self.shiftState {
            case .Disabled:
                self.shiftState = .Enabled
            case .Enabled:
                self.shiftState = .Enabled
            case .Locked:
                self.shiftState = .Locked
            }
            
            return true
        }
        else {
            switch self.shiftState {
            case .Disabled:
                self.shiftState = .Disabled
            case .Enabled:
                self.shiftState = .Disabled
            case .Locked:
                self.shiftState = .Locked
            }
            
            return false
        }
    }
    
    func characterIsPunctuation(character: Character) -> Bool {
        return (character == ".") || (character == "!") || (character == "?")
    }
    
    func characterIsNewline(character: Character) -> Bool {
        return (character == "\n") || (character == "\r")
    }
    
    func characterIsWhitespace(character: Character) -> Bool {
        // there are others, but who cares
        return (character == " ") || (character == "\n") || (character == "\r") || (character == "\t")
    }
    
    func stringIsWhitespace(string: String?) -> Bool {
        if string != nil {
            for char in (string!).characters {
                if !characterIsWhitespace(char) {
                    return false
                }
            }
        }
        return true
    }
    
    func shouldAutoCapitalize() -> Bool {
        if !MorphiiAPI.getUserDefaults().boolForKey(kAutoCapitalization) {
            return false
        }
        
        let traits = self.textDocumentProxy
        if let autocapitalization = traits.autocapitalizationType {
            let documentProxy = self.textDocumentProxy
            //var beforeContext = documentProxy.documentContextBeforeInput
            
            switch autocapitalization {
            case .None:
                return false
            case .Words:
                if let beforeContext = documentProxy.documentContextBeforeInput {
                    let previousCharacter = beforeContext[beforeContext.endIndex.predecessor()]
                    return self.characterIsWhitespace(previousCharacter)
                }
                else {
                    return true
                }
            
            case .Sentences:
                if let beforeContext = documentProxy.documentContextBeforeInput {
                    let offset = min(3, beforeContext.characters.count)
                    var index = beforeContext.endIndex
                    
                    for (var i = 0; i < offset; i += 1) {
                        index = index.predecessor()
                        let char = beforeContext[index]
                        
                        if characterIsPunctuation(char) {
                            if i == 0 {
                                return false //not enough spaces after punctuation
                            }
                            else {
                                return true //punctuation with at least one space after it
                            }
                        }
                        else {
                            if !characterIsWhitespace(char) {
                                return false //hit a foreign character before getting to 3 spaces
                            }
                            else if characterIsNewline(char) {
                                return true //hit start of line
                            }
                        }
                    }
                    
                    return true //either got 3 spaces or hit start of line
                }
                else {
                    return true
                }
            case .AllCharacters:
                return true
            }
        }
        else {
            return false
        }
    }
    
    // this only works if full access is enabled
    func playKeySound() {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            AudioServicesPlaySystemSound(1104)
        })
    }
    
    //////////////////////////////////////
    // MOST COMMONLY EXTENDABLE METHODS //
    //////////////////////////////////////
    
    class var layoutClass: KeyboardLayout.Type { get { return KeyboardLayout.self }}
    class var layoutConstants: LayoutConstants.Type { get { return LayoutConstants.self }}
    class var globalColors: GlobalColors.Type { get { return GlobalColors.self }}
    
    func keyPressed(key: Key) {
        self.textDocumentProxy.insertText(key.outputForCase(self.shiftState.uppercase()))
    }
    
    // a banner that sits in the empty space on top of the keyboard
    func createBanner() -> ExtraView? {
        // note that dark mode is not yet valid here, so we just put false for clarity
        //return ExtraView(globalColors: self.dynamicType.globalColors, darkMode: false, solidColorMode: self.solidColorMode())
        return nil
    }
    
    // a settings view that replaces the keyboard when the settings button is pressed
    func createSettings() -> ExtraView? {
        // note that dark mode is not yet valid here, so we just put false for clarity
        let settingsView = DefaultSettings(globalColors: self.dynamicType.globalColors, darkMode: false, solidColorMode: self.solidColorMode())
        settingsView.backButton?.addTarget(self, action: #selector(KeyboardViewController.toggleSettings), forControlEvents: UIControlEvents.TouchUpInside)
        return settingsView
    }
    
    func addMorphiiToFavorites (shareView:UIView, morphiiView:MorphiiWideView) {
        print("addMorphiiToFavorites1:",morphiiView.morphii.originalName)
        KeyboardViewController.returnKeyString = "return"
        self.shareView = shareView
        shareView.hidden = true
        recentView?.hidden = true
       // updateAppearances(true)
        if UIInterfaceOrientationIsPortrait(orientation) {
            setHeight(370)
        }else {
            setHeight(290)
        }
        viewDidLayoutSubviews()
        addFavoriteContainerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: 100))
        view.insertSubview(addFavoriteContainerView!, belowSubview: forwardingView)
        let widthConstraint = NSLayoutConstraint(item: addFavoriteContainerView!, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: addFavoriteContainerView!, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 100)
        let xConstraint = NSLayoutConstraint(item: addFavoriteContainerView!, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: addFavoriteContainerView!, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1, constant: 0)
        view.addConstraints([widthConstraint, heightConstraint, xConstraint, yConstraint])
        addFavoriteView = AddFavoriteContainerView(globalColors: self.dynamicType.globalColors, darkMode: true, solidColorMode: self.solidColorMode())
        addFavoriteView?.addToSuperView(addFavoriteContainerView!, morphiiWideView: morphiiView, delegate: self)
        addFavoriteView?.nameTextField.delegate = self
        addFavoriteView?.tagsTextField.delegate = self
    }
    
}

extension KeyboardViewController:AddFavoriteContainerViewDelegate {
    func closeButtonPressed () {
        addFavoriteContainerView?.removeFromSuperview()
        addFavoriteContainerView = nil
        setHeight(280)
        shareView?.hidden = false
        recentView?.hidden = false
    }
}

extension KeyboardViewController:UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let favoriteView = addFavoriteView else {return false}
        if string == "" {
            return true
        }
      textField.addTextSpacing(-0.4)
         textField.textColor = UIColor ( red: 0.2, green: 0.2235, blue: 0.2902, alpha: 1.0 )
        if favoriteView.tagsTextField == textField && string == " " {
            guard let wordsArray = favoriteView.tagsTextField.text?.componentsSeparatedByString(" ") else {return true}
            var newWords:[String] = []
            for var word in wordsArray {
                if let character = word.characters.first where "\(character)" != "#" {
                    word = "#\(word)"
                }
                newWords.append(word)
            }
            favoriteView.tagsTextField.text = newWords.joinWithSeparator(" ")
            print("WORDS:",newWords)
        }else if textField == favoriteView.tagsTextField {
            let characterSet = NSCharacterSet(charactersInString: acceptableCharacters)
            let filtered = string.componentsSeparatedByCharactersInSet(characterSet).joinWithSeparator("")
            return string != filtered
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        guard let favoriteView = addFavoriteView else {return false}
        guard let morphii = favoriteView.morphiiView.morphii else {return false}
      let tags = Morphii.getTagsFromString(favoriteView.tagsTextField.text)
        if let newMorphii = Morphii.createNewMorphii(favoriteView.nameTextField.text,
                                            name: favoriteView.nameTextField.text,
                                            scaleType: Int((morphii.scaleType!)),
                                            sequence: Int((morphii.sequence)!),
                                            groupName: "Your Saved Morphiis",
                                            metaData: morphii.metaData,
                                            emoodl: favoriteView.morphiiView.emoodl,
                                            isFavorite: true,
                                            tags: tags, order: 5000, originalId: morphii.id, originalName: morphii.name, showName: true) {

            addFavoriteContainerView?.removeFromSuperview()
            addFavoriteContainerView = nil
            setHeight(280)
            recentView?.backButtonPressed()
            shareView?.removeFromSuperview()
            shareView = nil
            recentView?.hidden = false
            setCenterView(.Favorites)
            MethodHelper.showSuccessErrorHUD(true, message: "Saved to Favorites", inView: self.view)
            MorphiiAPI.sendFavoriteData(morphii, favoriteNameO: favoriteView.nameTextField.text, emoodl: newMorphii.emoodl!.doubleValue, tags: tags)
            
            //HERE
            var area = ""
            switch centerView {
            case .Favorites:
                area = MorphiiAreas.keyboardFavorites
                break
            case .Home:
                area = MorphiiAreas.keyboardHome
                break
            case .Recents:
                area = MorphiiAreas.keyboardRecent
                break
            default:
                area = "Other"
                break
            }
            MorphiiAPI.sendMorphiiFavoriteSavedToAWS(favoriteView.morphiiView.morphii, intensity: favoriteView.morphiiView.emoodl, area: area, name: favoriteView.nameTextField.text!, originalName: favoriteView.morphiiView.morphii.originalName, tags: tags)
            print("MorphiiAPI.send")

        }
        return true
    }
}
