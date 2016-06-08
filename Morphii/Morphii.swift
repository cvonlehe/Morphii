//
//  Morphii.swift
//  Morphii
//
//  Created by netGALAXY Studios on 6/7/16.
//  Copyright © 2016 netGALAXY Studios. All rights reserved.
//

import UIKit

class Morphii: NSObject {
    var id: String = ""
    var name: String = ""
    var scaleType: Int = 0
    var staticUrl: String = ""
    var dataUrl: String = ""
    var changedDate: NSDate = NSDate()
    //let category: String
    //let keywords: [ String ]
    var sequence: Int = 0
    var pngString: String?
    var metaData: NSDictionary?
    
    
    init(id: String, name: String, scaleType: Int, staticUrl: String, dataUrl: String, changedDate: NSDate, /*category: String, keywords: [ String ],*/ sequence: Int, pngString: String, metaData: NSDictionary) {
        super.init()
        setData(id, name: name, scaleType: scaleType, staticUrl: staticUrl, dataUrl: dataUrl, changedDate: changedDate, sequence: sequence, pngString: pngString, metaData: metaData)
    }
    
    init (morphiiRecord:NSDictionary) {
        super.init()
        let data = morphiiRecord.valueForKey("data") as! NSDictionary
        let metaData = data.valueForKey("metaData") as! NSDictionary
        let scaleType = morphiiRecord.valueForKey("scaleType") as! Int
        let recId = morphiiRecord.valueForKey("id") as! String
        let recName = morphiiRecord.valueForKey("name") as! String
        print("THIS MORPHII IS NAMED\(recName)")
        let recStaticUrl = morphiiRecord.valueForKey("staticUrl") as! String
        let recDataUrl = morphiiRecord.valueForKey("dataUrl") as! String
        let recChangedDateNumber = morphiiRecord.valueForKey("changedDateUTC") as! NSNumber
        let recChangedDate = NSDate(timeIntervalSince1970: recChangedDateNumber.doubleValue)
        //let recCategory = morphiiRecords[i].valueForKey("category") as! String
        //let recKeywords = morphiiRecords[i].valueForKey("keywords") as! [ String ]
        let recSequence = morphiiRecord.valueForKey("sequence") as! Int
        let pngDataString = data.valueForKey("png") as! String
        setData(recId, name: recName, scaleType: scaleType, staticUrl: recStaticUrl, dataUrl: recDataUrl, changedDate: recChangedDate, sequence: recSequence, pngString: pngDataString, metaData: metaData)
    }
    
    private func setData(id: String, name: String, scaleType: Int, staticUrl: String, dataUrl: String, changedDate: NSDate, /*category: String, keywords: [ String ],*/ sequence: Int, pngString: String, metaData: NSDictionary) {
        self.id = id
        self.name = name
        self.scaleType = scaleType
        self.staticUrl = staticUrl
        self.dataUrl = dataUrl
        self.changedDate = changedDate
        //self.category = category
        //self.keywords = keywords
        self.sequence = sequence
        self.pngString = pngString
        self.metaData =  metaData
    }
    
    func getImage (completion:(imageO:UIImage?)->Void) {
        guard let png = pngString else {return}
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let data = NSData(base64EncodedString: png, options: NSDataBase64DecodingOptions())
            dispatch_async(dispatch_get_main_queue(), {
                if let d = data, let image = UIImage(data: d) {
                    completion(imageO: image)
                }else {
                    completion(imageO: nil)
                }
            })
        }
    }
}
