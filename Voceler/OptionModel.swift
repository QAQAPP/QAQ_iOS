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
    var oQuestion:QuestionModel!
    var isLiked = false{
        didSet{
            if isLiked{
//                oQuestion.choose(val: oRef.key)
                gameManager?.chooseOption()
                oRef.child("val").runTransactionBlock({ (data) -> FIRTransactionResult in
                    if let num = data.value as? Int{
                        data.value = num + 1
                    }
                    self.oQuestion.qRef.child("content").child("val").observeSingleEvent(of: .value, with: { (snapshot) in
                        if let num = snapshot.value as? Int{
                            self.oQuestion.qRef.child("content").child("val").setValue(num + 1)
                        }
                        else{
                            self.oQuestion.qRef.child("content").child("val").setValue(0)
                        }
                    })
                    return FIRTransactionResult.success(withValue: data)
                })
            }
            else{
                oRef.child("val").runTransactionBlock({ (data) -> FIRTransactionResult in
                    if let num = data.value as? Int{
                        data.value = num - 1
                    }
                    self.oQuestion.qRef.child("content").child("val").observeSingleEvent(of: .value, with: { (snapshot) in
                        if let num = snapshot.value as? Int{
                            self.oQuestion.qRef.child("content").child("val").setValue(num - 1)
                        }
                        else{
                            self.oQuestion.qRef.child("content").child("val").setValue(0)
                        }
                    })
                    return FIRTransactionResult.success(withValue: data)
                })
            }
        }
    }
    init(question:QuestionModel, description:String, offerBy:String? = nil, val:Int = 0) {
        oQuestion = question
        if let d = description.removingPercentEncoding{
            oDescription = d
        }
        else {
            oDescription = description
        }
        oOfferBy = offerBy
        oVal = val
    }
    init(question:QuestionModel, ref:FIRDatabaseReference, dict:Dictionary<String,Any>){
        oQuestion = question
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
