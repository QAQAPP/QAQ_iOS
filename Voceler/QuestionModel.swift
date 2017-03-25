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
    var notiVal = 0{
        didSet{
            controllerManager?.userVC.notiForCollection()
        }
    }
    
    init(qid:String, descrpt:String, askerID:String, anonymous:Bool=false, options:[OptionModel]) {
        super.init()
        self.qid = qid
        qRef.child("content").child("val").observe(.value, with: { (snapshot) in
            if let val = snapshot.value as? Int{
                self.notiVal = val
            }
            else{
                self.notiVal = 0
            }
        })
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
        let contentRef = ref.child("content")
        contentRef.child("description").setValue(qDescrption)
        contentRef.child("askerID").setValue(currUser!.uid)
        contentRef.child("anonymous").setValue(qAnonymous)
        contentRef.child("val").setValue(0)
        for opt in qOptions{
            let optRef = ref.child("options").childByAutoId()
            optRef.child("description").setValue(opt.oDescription)
            optRef.child("offerBy").setValue(qAskerID)
            optRef.child("val").setValue(0)
        }
        
        // Set up tags
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
        currUser?.collectQuestion(qid: qid, like: true)
        networkingManager?.concludeQuestion(qid: qid)
    }
    
    func removeFromCollection(){
        currUser?.qRef.child(qid).removeValue()
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
