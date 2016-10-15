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
    private let init_size:UInt = 10
    private var size:UInt = 10
    private var collection = [QuestionModel]()
    private var ref:FIRDatabaseReference!
    private var tagsRef:FIRDatabaseReference!
    private var isLoading = false
    private var questionKeySet = Set<String>()
    private var numOfTotalQuestions = 0
    
    override init() {
        super.init()
        ref = FIRDatabase.database().reference().child("Questions-v1")
        tagsRef = FIRDatabase.database().reference().child("Tags-v1")
        var initialLoading = true
        tagsRef.child("all").observe(.childAdded, with: { (snapshot) in
            if !initialLoading{
                self.size = self.init_size
                self.refreshCollection()
            }
            initialLoading = false
        })
    }
    private func refreshCollection() {
        if !isLoading{
            isLoading = true
            tagsRef.child("all").queryOrderedByPriority().queryLimited(toLast: size).observeSingleEvent(of: .value, with: { (snapshot) in
                if let value = snapshot.value as? Dictionary<String, Any>{
                    let setCount = self.questionKeySet.count
                    
                    // check if the key is checked, if not, add to the set and load the question
                    for (key, _) in value{
                        if !self.questionKeySet.contains(key){
                            self.questionKeySet.insert(key)
                            self.loadQuestion(qid: key)
                        }
                    }
                    
                    // if items is not enough, then pause
                    if value.count < Int(self.size) {
                        self.isLoading = false
                        return
                    }
                    
                    // if no new question is added into the set, then expand the size and reload data
                    if setCount == self.questionKeySet.count{
                        self.size += self.init_size
                        self.isLoading = false
                        self.refreshCollection()
                    }
                }
                self.isLoading = false
            })
        }
    }
    
    
    func loadQuestion(qid:String){
        if let uid = currUser?.uid{
            _ = FIRDatabase.database().reference().child("Questions-v1").child(qid).child("Users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.value is NSNull{
                    self.loadQuestionContent(qid: qid)
                }
                else{
                    self.numOfTotalQuestions += 1
                    if self.numOfTotalQuestions == self.questionKeySet.count{
                        self.size += self.init_size
                        self.refreshCollection()
                    }
                }
            })
        }
    }
    
    func loadQuestionContent(qid:String, purpose:String = "QuestionLoaded"){
        _ = FIRDatabase.database().reference().child("Questions-v1").child(qid).child("content").observeSingleEvent(of: .value, with: { (snapshot) in
            if purpose == "QuestionLoaded"{
                self.collection.append(self.getQuestion(qid: qid, question: snapshot.value as? Dictionary<String, Any>)!)
                self.numOfTotalQuestions += 1
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
//            if let opts = question["options"] as? Dictionary<String, Any>{
//                for (key, dict) in opts {
//                    optArr.append(OptionModel(ref: FIRDatabase.database().reference().child("Questions-v1").child(qid).child("content").child("options").child(key) ,dict: dict as! Dictionary<String, Any>))
//                }
//            }
            return QuestionModel(qid: qid, descrpt: question["description"] as! String, askerID: question["askerID"] as! String, anonymous: question["anonymous"] as! Bool, options: optArr)
        }
        else{
            return nil
        }
    }
    
    func getQuestion() -> QuestionModel?{
        if collection.isEmpty{
            refreshCollection()
        }
        return collection.popLast()
    }
    
//    func clean(){
//        isLoading = false
//        collection.removeAll()
//        questionKeySet.removeAll()
//        memoryHandler.imageStorage.removeAll()
//    }
}
