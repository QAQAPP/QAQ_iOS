//
//  QuestionManager.swift
//  Voceler
//
//  Created by 钟镇阳 on 9/23/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import Foundation
import FirebaseDatabase

class QuestionManager: NSObject {
    private var size:Int = 3
    private var collection = [QuestionModel]()
    private var ref:FIRDatabaseReference!
//    var isLoading = false
    
    override init() {
        super.init()
        ref = FIRDatabase.database().reference().child("Questions-v1")
        networkingManager?.getQuestion()
    }
    
    func loadQuestionContent(qid:String, purpose:String = "QuestionLoaded"){
        _ = FIRDatabase.database().reference().child("Questions-v1").child(qid).child("content").observeSingleEvent(of: .value, with: { (snapshot) in
            if purpose == "QuestionLoaded"{
                self.collection.append(self.getQuestion(qid: qid, question: snapshot.value as? Dictionary<String, Any>)!)
//                NotificationCenter.default.post(name: Notification.Name.QuestionLoaded, object: nil)
                controllerManager?.mainVC.addContent()
            }
            if purpose != "QuestionLoaded" || self.collection.count < 2{
                if var dict = snapshot.value as? Dictionary<String, Any>{
                    dict["qid"] = qid
                    NotificationCenter.default.post(name: Notification.Name(purpose), object: dict)
                }
            }
        })
    }
    
    func getQuestion(qid: String?, question:Dictionary<String, Any>?)->QuestionModel?{
        if let qid = qid, let question = question{
            let optArr = [OptionModel]()
            return QuestionModel(qid: qid, descrpt: question["description"] as! String, askerID: question["askerID"] as! String, anonymous: question["anonymous"] as! Bool, options: optArr)
        }
        else{
            return nil
        }
    }
    
    func getQuestion() -> QuestionModel?{
        if collection.count < 3{
            networkingManager?.getQuestion()
        }
        return collection.popLast()
    }
}
