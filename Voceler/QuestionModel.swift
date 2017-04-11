//
//  QuestionModel.swift
//  Voceler
//
//  Created by 钟镇阳 on 8/23/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import Foundation
import FirebaseDatabase
import SCLAlertView

class QuestionModel: NSObject {
    var qDescrption:String! // Question Description
    var qAskerID:String! // UID
    var qAnonymous = false // Don't show the asker to public
    var qTags = [String]()
    var qViews = 0
    var qOptions = [FIRDatabaseReference]()
    var qRef:FIRDatabaseReference!
    var userChoosed = false
    var notiVal = 0{
        didSet{
            controllerManager?.userVC.setupBadgeValueForCollectionCell()
        }
    }
    
    init(qid:String, descrpt:String, askerID:String) {
        super.init()
        self.qRef = FIRDatabase.database().reference().child("Questions-v1").child(qid)
        qRef.child("content").child("val").observe(.value, with: { (snapshot) in
            if let val = snapshot.value as? Int{
                self.notiVal = val
            }
            else{
                self.notiVal = 0
            }
        })
        qRef.child("options").observe(.childAdded, with: { (snapshot) in
            self.qOptions.append(self.qRef.child("options").child(snapshot.key))
        })
        qDescrption = descrpt
        qAskerID = askerID
    }
    
    override init(){
        super.init()
    }
    
    func postQuestion(){
        if !gameManager!.checkAskQuestion(){
            return
        }
        
        _ = gameManager!.askQuestion(charge: true)
        // Set up question
        let ref = FIRDatabase.database().reference().child("Questions-v1").childByAutoId()
        let contentRef = ref.child("content")
        contentRef.child("description").setValue(qDescrption)
        contentRef.child("askerID").setValue(currUser!.uid)
        contentRef.child("val").setValue(0)
//        for opt in qOptions{
//            let optRef = ref.child("options").childByAutoId()
//            optRef.child("description").setValue(opt.oDescription)
//            optRef.child("offerBy").setValue(qAskerID)
//            optRef.child("val").setValue(0)
//        }
        
        // Set up tags
        networkingManager?.updateTags(text: qDescrption, tags: qTags)
        networkingManager?.addQuestion(qid: ref.key, tags: qTags)
        
        // Add question to user
        
        currUser!.qRef.child(ref.key).setValue("In progress")
        currUser!.qInProgress.append(ref.key)
        NotificationCenter.default.post(name: Notification.Name("qInProgressLoaded"), object: toDict())
    }
    
    func toDict()->Dictionary<String,Any>{
        var dict = Dictionary<String, Any>()
        dict["qid"] = qRef.key
        dict["anonymous"] = qAnonymous
        dict["askerID"] = qAskerID
        dict["description"] = qDescrption
        return dict
    }
    
    // load to opt array
    func optArrAdd(option:FIRDatabaseReference){
        for opt in qOptions{
            if opt.key == option.key{
                return
            }
        }
        qOptions.append(option)
    }
    
    // add to database
    func addOption(opt:OptionModel){
        let optRef = qRef.child("options").childByAutoId()
        opt.oRef = optRef
        optRef.child("description").setValue(opt.oDescription)
        optRef.child("offerBy").setValue(opt.oOfferBy)
        opt.isLiked = true
        optRef.child("val").setValue(opt.oVal)
        qRef.child("Users").child(currUser!.uid).setValue(optRef.key)
        changeNotiVal(val: 1)
        gameManager?.addOption()
    }
    
    // TODO: conclude question
    func conclude(oid:String? = nil){
        if let oid = oid{
            qRef.child("content").child("conclusion").setValue(oid)
        }
        else{
            qRef.child("content").child("conclusion").setValue("nil")
        }
        currUser?.collectQuestion(qid: qRef.key, like: true)
        networkingManager?.concludeQuestion(qid: qRef.key)
    }
    
    func removeFromCollection(){
        currUser?.qRef.child(qRef.key).removeValue()
    }
    
    func changeNotiVal(val:Int){
        qRef.child("content").child("val").observeSingleEvent(of: .value, with: { (snapshot) in
            if let num = snapshot.value as? Int{
                self.qRef.child("content").child("val").setValue(num + val)
            }
            else{
                self.qRef.child("content").child("val").setValue(0)
            }
        })
    }
    
    func clearNotiVal(){
        qRef.child("content").child("val").setValue(0)
    }
}
