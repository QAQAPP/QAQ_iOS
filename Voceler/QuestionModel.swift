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
    var qid:String!
    var qDescrption:String! // Question Description
    var qAskerID:String! // UID
    var qAnonymous = false // Don't show the asker to public
    var qOptions = [OptionModel]() // Question options (option id: OID)
    var qTags = [String]()
    var qViews = 0
    var qRef:FIRDatabaseReference!{
        return FIRDatabase.database().reference().child("Questions-v1").child(qid)
    }
    var userChoosed = false
    
    init(qid:String, descrpt:String, askerID:String, anonymous:Bool=false, options:[OptionModel]) {
        super.init()
        self.qid = qid
        qDescrption = descrpt
        qAskerID = askerID
        qAnonymous = anonymous
        qOptions = options
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
        qid = ref.key
        ref.child("owner").setValue(currUser!.uid)
        let contentRef = ref.child("content")
        contentRef.child("description").setValue(qDescrption)
        contentRef.child("askerID").setValue(qAskerID)
        contentRef.child("anonymous").setValue(qAnonymous)
        contentRef.child("val").setValue(0)
        for opt in qOptions{
            let optRef = ref.child("options").childByAutoId()
            optRef.child("description").setValue(opt.oDescription)
            optRef.child("offerBy").setValue(qAskerID)
            optRef.child("val").setValue(0)
        }
        
        // Set up tags
//        ref.child("tags").setValue(qTags)
//        let tagRef = FIRDatabase.database().reference().child("Tags-v1")
//        let allTagRef = tagRef.child("all").child(qid)
//        allTagRef.setValue("1")
//        for tag in qTags{
//            let ref = tagRef.child(tag).child(QID)
//            ref.setValue("0")
//            ref.setPriority(qPriority)
//        }
        networkingManager?.updateTags(text: qDescrption, tags: qTags)
        networkingManager?.addQuestion(qid: qid, tags: qTags)
        
        // Add question to user
        
        currUser!.qRef.child(qid).setValue("In progress")
        currUser!.qInProgress.append(qid)
        NotificationCenter.default.post(name: Notification.Name("qInProgressLoaded"), object: toDict())
    }
    
    func toDict()->Dictionary<String,Any>{
        var dict = Dictionary<String, Any>()
        dict["qid"] = qid
        dict["anonymous"] = qAnonymous
        dict["askerID"] = qAskerID
        dict["description"] = qDescrption
        return dict
    }
    
    // load to opt array
    func optArrAdd(option:OptionModel){
        for opt in qOptions{
            if opt.oRef.key == option.oRef.key{
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
        gameManager?.addOption()
    }
    
//    func choose(val:String = "skipped"){
//        qRef.child("Users").child(currUser!.uid).setValue(val)
//        if val != "skipped" && val != "owner"{
//        gameManager?.chooseOption()
//        }
//    }
    
    func conclude(oid:String? = nil){
        if let oid = oid{
            qRef.child("content").child("conclusion").setValue(oid)
        }
        else{
            qRef.child("content").child("conclusion").setValue("nil")
        }
        FIRDatabase.database().reference().child("Tags-v1").child("all").child(qid).removeValue()
        currUser?.collectQuestion(qid: qid, like: true)
    }
    
    func removeFromCollection(){
        currUser?.qRef.child(qid).removeValue()
    }
}
