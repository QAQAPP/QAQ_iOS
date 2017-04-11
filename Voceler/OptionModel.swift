//
//  OptionModel.swift
//  Voceler
//
//  Created by 钟镇阳 on 9/23/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import SCLAlertView

class OptionModel: NSObject {
    weak var optionViewTableCell:OptViewTableCell?
    var oDescription = ""{
        didSet{
            optionViewTableCell?.textView.text = oDescription
        }
    }
    var offererImage = #imageLiteral(resourceName: "user-50"){
        didSet{
            optionViewTableCell?.profileImg.setImage(offererImage, for: .normal)
        }
    }
    var oOfferBy:String!{
        didSet{
            FIRStorage.storage().reference().child("Users").child(oOfferBy).child("profileImg.jpeg").data(withMaxSize: 1024*1024) { (data, error) in
                if let data = data{
                    self.offererImage = UIImage(data: data)!
                }
                else {
                    self.offererImage = #imageLiteral(resourceName: "user-50")
                }
            }
        }
    }
    var oVal = 0{
        didSet{
            optionViewTableCell?.setNumLikes(num: oVal)
        }
    }
    var oRef:FIRDatabaseReference!
//    var oQuestion:QuestionModel!
    var isLiked = false{
        didSet{
            if isLiked{
//                oQuestion.choose(val: oRef.key)
                gameManager?.chooseOption()
                optionViewTableCell?.likeBtn.setImage(#imageLiteral(resourceName: "check_checked"), for: .normal)
                oRef.child("val").runTransactionBlock({ (data) -> FIRTransactionResult in
                    if let num = data.value as? Int{
                        data.value = num + 1
                    }
                    self.changeNotiVal(val: 1)
                    return FIRTransactionResult.success(withValue: data)
                })
            }
            else{
                optionViewTableCell?.likeBtn.setImage(#imageLiteral(resourceName: "check"), for: .normal)
                oRef.child("val").runTransactionBlock({ (data) -> FIRTransactionResult in
                    if let num = data.value as? Int{
                        data.value = num - 1
                    }
                    self.changeNotiVal(val: -1)
                    return FIRTransactionResult.success(withValue: data)
                })
            }
        }
    }
    init(optCell:OptViewTableCell) {
        optionViewTableCell = optCell
    }
    
    func setRef(ref:FIRDatabaseReference){
        oRef = ref
        oRef.child("description").observe(.value, with: { (snapshot) in
            if let text = snapshot.value as? String{
                self.oDescription = text
            }
        })
        oRef.child("val").observe(.value, with: { (snapshot) in
            if let val = snapshot.value as? Int{
                self.oVal = val
            }
        })
        oRef.child("offerBy").observe(.value, with: { (snapshot) in
            if let uid = snapshot.value as? String{
                self.oOfferBy = uid
            }
        })
    }
    
    static func postPotion(question: FIRDatabaseReference, description: String, offerBy: String?){
        let ref = question.child("options").childByAutoId()
        ref.child("description").setValue(description)
        ref.child("val").setValue(0)
        ref.child("offerBy").setValue(offerBy)
    }
    
    
    func changeNotiVal(val:Int){
        if let ref = oRef.parent?.parent?.child("content").child("val"){
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let num = snapshot.value as? Int{
                    ref.setValue(num + val)
                }
                else{
                    ref.setValue(0)
                }
            })
        }
    }
}



