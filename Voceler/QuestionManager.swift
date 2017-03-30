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
    private var collectionMaxSize = 3
    private var collection = [QuestionModel]()
    private var ref:FIRDatabaseReference!
    private var numOfTotalQuestions = 0
    
    override init() {
        super.init()
        ref = FIRDatabase.database().reference().child("Questions-v1")
        networkingManager?.getQuestion(num: collectionMaxSize)
    }
    
    func loadQuestionContent(qid:String, purpose:String = "QuestionLoaded"){
        _ = FIRDatabase.database().reference().child("Questions-v1").child(qid).child("content").observeSingleEvent(of: .value, with: { (snapshot) in
            if purpose == "QuestionLoaded"{
                if let dict = snapshot.value as? Dictionary<String, Any>, let thisQuestion = self.getQuestion(qid: qid, question: dict){
//                    let thisQuestion = self.getQuestion(qid: qid, question: dict)!
                    self.collection.append(thisQuestion)
                    self.numOfTotalQuestions += 1
                    NotificationCenter.default.post(name: Notification.Name.QuestionLoaded, object: nil)
                    
    //                NotificationCenter.default.post(name: NSNotification.Name(rawValue: qid+"question"), object: nil, userInfo: ["description": thisQuestion.qDescrption])
                }
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
        if collection.count < collectionMaxSize{
            networkingManager?.getQuestion(num: collectionMaxSize - collection.count)
        }
        return collection.popLast()
    }
}
