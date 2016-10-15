//
//  OptionModel.swift
//  Voceler
//
//  Created by 钟镇阳 on 9/23/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import FirebaseDatabase

class OptionModel: NSObject {
    var oDescription = ""
    var oOfferBy:String?
    var oVal = 0
    var oRef:FIRDatabaseReference!
    init(description:String, offerBy:String? = nil, val:Int = 0) {
        if let d = description.removingPercentEncoding{
            oDescription = d
        }
        else {
            oDescription = description
        }
        oOfferBy = offerBy
        oVal = val
    }
    init(ref:FIRDatabaseReference, dict:Dictionary<String,Any>){
        oRef = ref
        oDescription = dict["description"] as! String
        if let offerBy = dict["offerBy"] as? String{
            oOfferBy = offerBy
        }
        if let val = dict["val"] as? Int{
            oVal = val
        }
        else{
            oVal = 0
        }
    }
}
