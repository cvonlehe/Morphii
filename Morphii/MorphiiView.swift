//
//  morphiiView.swift
//  morphyJSONcp
//
//  Created by Corley Higgins on 1/13/16.
//  Copyright © 2016 Corley Higgins. All rights reserved.
//

//import Foundation
//
//  morphyView.swift
//  morphyJSON
//
//  Created by Corley Higgins on 6/22/14.
//  Copyright (c) 2014 Corley Higgins. All rights reserved.
//

import UIKit
import Foundation
import Photos

protocol MorphiiProtocol{
    func smileForMorphiiView(sender:MorphiiView) -> Double
}

class MorphiiView: UIView, MorphiiProtocol {
    
    var dataSource:MorphiiProtocol?
    var beginningIntensity = 50.0
    
    //var morphy:MorphyObj?
    //var morphii:MorphiiClass.MorphiiFile!
    var morphii:Morphii!
    private var completion:((hasAccess:Bool, success:Bool)->Void)?
    var area:String?
    
    override init(frame: CGRect){
        super.init(frame: frame)
        // Initialization code
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
    func setUpMorphii(morphii:Morphii, emoodl:Double?){
        self.morphii = morphii
        setUpMorphiiGestures()
        if let e = emoodl {
            self.emoodl = e
        }else if let number = morphii.emoodl {
            self.emoodl = number.doubleValue
        }
//        emoodl = 45.0
    }
    
    var emoodl: Double = 50.0 {
        didSet(newValue){
            newValue
            self.setNeedsDisplay()
        }
    }
    
    struct Point{
        var x : NSNumber! = 0
        var y: NSNumber! = 0
    }
    
    struct Curv {
        var index: Int!=0, x1: NSNumber!=0.0, y1: NSNumber!=0.0, x2: NSNumber!=0.0, y2: NSNumber!=0.0, x: NSNumber!=0.0, y: NSNumber!=0.0
    }
    
    struct Segment{
        var key:String
        var color:AnyObject
        var st = Point()
        //var curvs:Array? = [Curv]()
        var curvs: [Curv]?
        
        
    }
    
    func calculatePath(seg: NSString, anchorSeg:NSDictionary, intensity:Double, deltaSeg:NSDictionary) -> Segment {
        
        let segNumb:Int = anchorSeg.count
        
        //let intensity = nintensity * -1
        
        //convert hex color to UIColor
        let segHexColor:String = anchorSeg.valueForKeyPath("color") as! String
        let segColor:UIColor = colorWithHexString(segHexColor)
        
        let stx = anchorSeg.valueForKeyPath("st.x") as! Double + (intensity * (deltaSeg.valueForKeyPath("st.x") as! Double))
        let sty = anchorSeg.valueForKeyPath("st.y") as! Double + (intensity * (deltaSeg.valueForKeyPath("st.y") as! Double))
        
        var segment = Segment(key: seg as String, color:segColor, st: Point(x: stx, y: sty), curvs: nil)
        
        var curvSeg = [ Curv ]()
        
        
        
        for (var s = 1; s < segNumb - 2; s++){
            
            let curvx1 = "c\(s).x1"
            let curvy1 = "c\(s).y1"
            let curvx2 = "c\(s).x2"
            let curvy2 = "c\(s).y2"
            let curvx = "c\(s).x"
            let curvy = "c\(s).y"
                        
            let cix1 = anchorSeg.valueForKeyPath(curvx1) as! Double + (intensity * (deltaSeg.valueForKeyPath(curvx1) as! Double))
            let ciy1 = anchorSeg.valueForKeyPath(curvy1) as! Double + (intensity * (deltaSeg.valueForKeyPath(curvy1) as! Double))
            let cix2 = anchorSeg.valueForKeyPath(curvx2) as! Double + (intensity * (deltaSeg.valueForKeyPath(curvx2) as! Double))
            let ciy2 = anchorSeg.valueForKeyPath(curvy2) as! Double + (intensity * (deltaSeg.valueForKeyPath(curvy2) as! Double))
            let cix = anchorSeg.valueForKeyPath(curvx) as! Double + (intensity * (deltaSeg.valueForKeyPath(curvx) as! Double))
            let ciy = anchorSeg.valueForKeyPath(curvy) as! Double + (intensity * (deltaSeg.valueForKeyPath(curvy) as! Double))
            
            let oneCurv = Curv(index: s, x1: cix1, y1: ciy1, x2: cix2, y2: ciy2, x: cix, y: ciy)
            
            curvSeg.append(oneCurv)
            
            segment.curvs = curvSeg
            
        }
        return segment
        
    }
    
    func setPathSegs(anchor:NSDictionary?, intensity:Double, delta:NSDictionary) -> [ Segment ] {
        var CurrentMorphii = [ Segment ]()
        
        //handle optional
        if let anchor = anchor {
            
            
            //remove it:
            for(key, _) in anchor {
                let anchorPart:NSDictionary = anchor.valueForKeyPath(key as! String)as! NSDictionary
                let deltaPart:NSDictionary = delta.valueForKeyPath(key as! String)as! NSDictionary
                
                let pathCalculation = calculatePath(key as! String, anchorSeg: anchorPart, intensity: intensity, deltaSeg: deltaPart)
                
                CurrentMorphii.append(pathCalculation)
            }
        }
        
        return CurrentMorphii
    }
    
    func buildMorphii(morphii:NSDictionary) -> [ Segment ] {
        //print("MORPHII BUILDING WITH MORPHII \(morphii)")
        //let anchorString = morphii.valueForKey("anchor") as! String
        //print("ANCHOR DICTIONARY IS \(anchorString)")
        //let deltaString = morphii.valueForKey("deltas") as! String
        //convert morphii string
        //var anchorData: NSData = anchorString.dataUsingEncoding(NSUTF8StringEncoding)!
        //var deltaData: NSData = deltaString.dataUsingEncoding(NSUTF8StringEncoding)!
        
        //convert it
        /*var anchorDict:NSDictionary? = nil
        var deltaDict:NSDictionary? = nil
        
        do {
            //anchorDict = try (NSJSONSerialization.JSONObjectWithData(anchorData, options: NSJSONReadingOptions.MutableContainers)as? NSDictionary)
            //deltaDict = try (NSJSONSerialization.JSONObjectWithData(deltaData, options: NSJSONReadingOptions.MutableContainers)as? NSDictionary)
        }
        catch{
            print("Handle \(error) here")
        }*/
        
        
        
        /*let anch:NSDictionary = morphii.valueForKeyPath("anchor")as! NSDictionary
        let delt:NSDictionary = morphii.valueForKeyPath("delta") as! NSDictionary*/
        
        let anchorDict = morphii.valueForKey("anchor") as! NSDictionary
        //print("ANCHOR DICTIONARY IS \(anchorDict)")
        let deltasDict = morphii.valueForKey("deltas") as! NSDictionary
        
        
        let deltaDict = deltasDict.valueForKey("DELTA1") as! NSDictionary
        //print("DELTA DICTIONARY IS \(deltaDict)")
        
        let anch = anchorDict
        let delt = deltaDict
        
        var intensityVal = self.dataSource?.smileForMorphiiView(self)
        
        if intensityVal > 1 { intensityVal = 1 }
        if intensityVal < 0 { intensityVal = 0 }
        
        let negIntensity = intensityVal! * -1
        
        let newAnch = setPathSegs(anch, intensity: negIntensity, delta: delt)
        return newAnch
        
    }
    
    func colorWithHexString (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substringFromIndex(1)
        }
        
        if (cString.characters.count != 6) {
            return UIColor.grayColor()
        }
        
        let rString = (cString as NSString).substringToIndex(2)
        let gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
        let bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        NSScanner(string: rString).scanHexInt(&r)
        NSScanner(string: gString).scanHexInt(&g)
        NSScanner(string: bString).scanHexInt(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
    
    var morphyRect:CGRect = CGRect(origin: CGPoint(x:10, y:112), size: CGSize(width: 300, height: 300))
    
    //override func drawRect(rect: CGRect)
    override func drawRect(rect: CGRect)
    {
        // Drawing code
        let colorSpace:CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()!
        let context:CGContextRef = UIGraphicsGetCurrentContext()!
        
        self.bounds.size = rect.size
        self.setNeedsDisplay()
        
        //our morphii svg's are 478x478 but are drawn in 300x300 so here's the const:
        let mScale = ((rect.size.width) / 478) as CGFloat
        
        CGContextScaleCTM(context, mScale, mScale)
        
        
        var midpoint = CGPoint(x: self.bounds.origin.x + self.bounds.size.width/2, y: self.bounds.origin.y + self.bounds.size.height/2)
        self.backgroundColor = UIColor.clearColor()
        
        //render morphii
        func renderMorphii (morphii: [Segment]) -> CGContextRef {
            let sortedMorphii = morphii.sort({ $0.key < $1.key })
            for seg in sortedMorphii {
                
                let morphiiSeg = seg
                
                let color = morphiiSeg.color
                let st = morphiiSeg.st
                let curvs = morphiiSeg.curvs!
                
                color.setFill()
                CGContextBeginPath(context)
                CGContextMoveToPoint(context, CGFloat(st.x), CGFloat(st.y))
                
                for curv in curvs {
                    
                    let curvx1 = curv.x1
                    let curvy1 = curv.y1
                    let curvx2 = curv.x2
                    let curvy2 = curv.y2
                    let curvx = curv.x
                    let curvy = curv.y
                    
                    CGContextAddCurveToPoint(context, CGFloat(curvx1), CGFloat(curvy1), CGFloat(curvx2), CGFloat(curvy2), CGFloat(curvx), CGFloat(curvy))
                }
                CGContextClosePath(context)
                CGContextFillPath(context)
            }
            return context
            
        }
        
        if self.morphii != nil {
            if let metaData = morphii.metaData {
                let morphii = buildMorphii(metaData)
                //let morphii = buildMorphii(self.morphy!.morphEr!)
                //let morphii = buildMorphii(self.morphy!.morphiiDict!)
                renderMorphii(morphii)
            }
        }
        
        
    }
    
    func setUpMorphiiGestures(){
        dataSource = self
        let panNizer = UIPanGestureRecognizer()
        panNizer.addTarget(self, action: #selector(MorphiiView.showGestureForPanRecognizer(_:)))
        addGestureRecognizer(panNizer)
    }
    
    func showGestureForPanRecognizer(recognizer: UIPanGestureRecognizer) {
        let beginIntensity = NSNumber(double: beginningIntensity)
        if recognizer.state == UIGestureRecognizerState.Changed || recognizer.state == UIGestureRecognizerState.Ended {
            let translation:CGPoint = recognizer.translationInView(self)
            if (self.morphii.scaleType == 1){
                //for "positive" emotions use this translation:SCALE TYPE 1
                self.emoodl -= (Double(translation.y)) / 2.5
            } else  if (self.morphii.scaleType == 2){
                //for "positive" emotions use this translation:SCALE TYPE 2
                self.emoodl -= (Double(translation.y)) / 2.5
            } else {
                //for "negative" emotions use this translation:SCALE TYPE 3
                self.emoodl -= (Double(translation.y)) / 2.5
            }
            print("EMOODL:",self.emoodl)
            recognizer.setTranslation(CGPointZero, inView: self)
        }
        if emoodl > 100 {
            emoodl = 100
        }else if emoodl < 0 {
            emoodl = 0
        }
        if recognizer.state == .Ended {
            let endIntensity = NSNumber(double: emoodl)
            print("BEGIN:",beginIntensity,"END:",endIntensity,"AREA:",area)
            if beginIntensity.doubleValue != endIntensity.doubleValue {
                MorphiiAPI.sendIntensityChangeToAWS(morphii, beginIntensity: beginIntensity, endIntensity: endIntensity, area: area)
            }
        }else if recognizer.state == .Began {
            beginningIntensity = emoodl
        }
    }
    
    func smileForMorphiiView(sender:MorphiiView) -> Double{
        return (Double((self.emoodl - 0) / 83))
        
    }
    
    func shareMorphii(viewController:UIViewController) {
        //let pasteData = copyMorphyToClipboard()
        //        if !MethodHelper.shouldNotAddURLToMessages() {
        //            let string = "Check out Morphii Keyboard: "+URLs.appStoreURL
        //            shareObjects.append(string)
        //        }
        var shareText = ""
        if !MethodHelper.shouldNotAddURLToMessages() {
            let string = "Sent by Morphii Keyboard: "+Config.getCurrentConfig().appStoreUrl
            shareText = string
        }
        let vc = UIActivityViewController(activityItems: [shareText, getMorphiiImage()], applicationActivities: [])
        viewController.presentViewController(vc, animated: true, completion: nil)
        vc.completionWithItemsHandler = {(activityType, completed:Bool, returnedItems:[AnyObject]?, error: NSError?) in
            
            // Return if cancelled
            if (completed) {
                if let type = activityType {
                    if type == UIActivityTypeCopyToPasteboard {
                        self.morphii.setLastUsedDate(NSDate())
                    }
                    let type = "\(type)"
                    print("TYPE:",type)
                    var name = ""
                    if let n = self.morphii.name {
                        name = n
                    }
                    MorphiiAPI.sendMorphiiSendToAWS(self.morphii, intensity: self.emoodl, area: self.area, name: name, share: type)
                }
            }
            
            //activity complete
            //some code here
            
            
        }
        
    }
    
    func copyMorphyToClipboard() -> Bool{

        
        //copy that image to the pasteboard
        guard let pasteBoard:UIPasteboard = UIPasteboard(name: UIPasteboardNameGeneral, create: false) else {return false}
        pasteBoard.persistent = true
        let pbData:NSData = UIImagePNGRepresentation(getMorphiiImage())!
        pasteBoard.setValue(pbData, forPasteboardType:"public.png")
//        let string = "Sent by Morphii Keyboard: "+Config.getCurrentConfig().appStoreUrl
//        pasteBoard.setValue(string, forPasteboardType: "public.plain-text")
        if let value = pasteBoard.dataForPasteboardType("public.png") {
            if value == pbData {
                morphii.setLastUsedDate(NSDate())
                return true
            }
        }
        return false
    }
    
    func saveMorphiiToSavedPhotos (completion:((hasAccess:Bool, success:Bool)->Void)?) {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .Authorized:
                self.completion = completion
                UIImageWriteToSavedPhotosAlbum(self.getMorphiiImage(), self, #selector(MorphiiView.image(_:didFinishSavingWithError:contextInfo:)), nil)
                break
            case .Restricted:
                print("Restricted")
                break
            case .Denied:
                print("Denied")
                if let comp = completion {
                    comp(hasAccess: false, success: false)
                }
                break
            default:
                // place for .NotDetermined - in this callback status is already determined so should never get here
                break
            }
        }

    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        if let com = completion {
            com(hasAccess:true, success: error == nil)
        }
    }
    
    func getMorphiiImage () -> UIImage {
//        let screenSize: CGRect = UIScreen.mainScreen().bounds
//        var clipMorphySize = CGSize(width: screenSize.width, height: screenSize.height)
//        UIGraphicsBeginImageContextWithOptions(clipMorphySize, false, 0.0)
//        var context:CGContextRef = UIGraphicsGetCurrentContext()!
//        layer.renderInContext(context)
//        var snapShotImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
//        
//        //crop the snapshot image of the context to be 300x300
//        //the cropping function
//        func croppedImage(bounds:CGRect) -> UIImage{
//            let imageRef:CGImageRef = CGImageCreateWithImageInRect(snapShotImage.CGImage, bounds)!
//            let croppedImage:UIImage = UIImage(CGImage: imageRef)
//            
//            return croppedImage
//        }
//        
//        //bounding rectangle for cropping morphy's image
//        //must be in pixels because of the conversion from UIImage to CGImageRef
//        //width is longer so morphii will fit in text bubble
//        let cropRect:CGRect = CGRectMake(0, 0, 600, 600)
//        //let cropRect:CGRect = CGRectMake(-10, 0, 545, 525)
//        
//        //crop the snapshot with the bounding rectangle
//        let morphyPic = croppedImage(cropRect)
//        
//        //image insets
//        let morphiiInsets = UIEdgeInsetsMake(10, 20, 10, 20)
//        let morphiiPic = morphyPic.imageWithInsets(morphiiInsets)
//        
//        
//        //end the graphics context
//        UIGraphicsEndImageContext()
        clipsToBounds = true
        let color = backgroundColor
        backgroundColor = UIColor ( red: 0.3334, green: 0.3333, blue: 0.3334, alpha: 1.0 )
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let morphiiPic = UIGraphicsGetImageFromCurrentImageContext()
        morphiiPic.drawInRect(CGRect(x: 0, y: 0, width: 600, height: 600))
        UIGraphicsEndImageContext()
        layer.cornerRadius = 0
        backgroundColor = UIColor.clearColor()
        setUpMorphii(morphii, emoodl: emoodl)
        if var newImage = removeWhiteBackgroundFromImage(morphiiPic) {
            print("NEW_IMAGE123:",newImage)
            newImage = newImage.imageWithInsets(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
            return newImage
        }

        return morphiiPic
    }
    
    func removeWhiteBackgroundFromImage (oldImage:UIImage) -> UIImage? {
        
        let image = UIImage(data: UIImageJPEGRepresentation(oldImage, 1.0)!)!

        let rawImageRef: CGImageRef = image.CGImage!
        let components = CGColorGetComponents(UIColor.darkGrayColor().CGColor)
        let min = CGFloat(80.0)
        let max = CGFloat(90.0)
        let colorMasking: [CGFloat] = [min, max, min, max, min, max]
        UIGraphicsBeginImageContext(image.size);
        let maskedImageRef=CGImageCreateWithMaskingColors(rawImageRef, colorMasking);
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0.0, image.size.height);
        CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
        CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, image.size.width, image.size.height), maskedImageRef);
        CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), false)
        let result = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return result
    }
}

extension UIImage {
    func imageWithInsets(insets: UIEdgeInsets) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(
            CGSizeMake(self.size.width + insets.left + insets.right,
                self.size.height + insets.top + insets.bottom), false, self.scale)
        let context = UIGraphicsGetCurrentContext()
        let origin = CGPoint(x: insets.left, y: insets.top)
        self.drawAtPoint(origin)
        let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageWithInsets
    }
}


