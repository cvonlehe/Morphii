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
    //let category: String
    //let keywords: [ String ]
    var sequence: Int = 0
    var metaData: NSDictionary?
    
    
    init(id: String, name: String, scaleType: Int, /*category: String, keywords: [ String ],*/ sequence: Int, metaData: NSDictionary) {
        super.init()
        setData(id, name: name, scaleType: scaleType, sequence: sequence, metaData: metaData)
    }
    
    init (morphiiRecord:NSDictionary) {
        super.init()
        let data = morphiiRecord.valueForKey(MorphiiAPIKeys.data) as! NSDictionary
        let metaData = data.valueForKey(MorphiiAPIKeys.metaData) as! NSDictionary
        let scaleType = morphiiRecord.valueForKey(MorphiiAPIKeys.scaleType) as! Int
        let recId = morphiiRecord.valueForKey(MorphiiAPIKeys.id) as! String
        let recName = morphiiRecord.valueForKey(MorphiiAPIKeys.name) as! String
        //let recCategory = morphiiRecords[i].valueForKey("category") as! String
        //let recKeywords = morphiiRecords[i].valueForKey("keywords") as! [ String ]
        let recSequence = morphiiRecord.valueForKey(MorphiiAPIKeys.sequence) as! Int
        setData(recId, name: recName, scaleType: scaleType, sequence: recSequence, metaData: metaData)
    }
    
    private func setData(id: String, name: String, scaleType: Int, /*category: String, keywords: [ String ],*/ sequence: Int, metaData: NSDictionary) {
        self.id = id
        self.name = name
        self.scaleType = scaleType
        //self.category = category
        //self.keywords = keywords
        self.sequence = sequence
        self.metaData =  metaData
    }
    
    func getImage (completion:(imageO:UIImage?)->Void) {
        completion(imageO: nil)
//        guard let png = pngString else {return}
//        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
//            let data = NSData(base64EncodedString: png, options: NSDataBase64DecodingOptions())
//            dispatch_async(dispatch_get_main_queue(), {
//                if let d = data, let image = UIImage(data: d) {
//                    completion(imageO: image)
//                }else {
//                    completion(imageO: nil)
//                }
//            })
//        }
    }
}
