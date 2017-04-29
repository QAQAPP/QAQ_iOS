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
    private var ref = databaseQuestionRef
    private var numOfTotalQuestions = 0
    
    // Arrays to hold loaded questions
    var qInProgressArr = Array<FIRDatabaseReference>()
    var qCollectionArr = Array<FIRDatabaseReference>()
    var qConcludedArr = Array<FIRDatabaseReference>()
    var qMainArr = Array<FIRDatabaseReference>()

    
    override init() {
        super.init()
        networkingManager?.getQuestion(num: collectionMaxSize)
        databaseUserRef.child(currUser!.ref.key).child("Questions").observe(.childAdded, with: { (snapshot) in
            if let type = snapshot.value as? String{
                let ref = databaseQuestionRef.child(snapshot.key)
                switch type{
                    case "In progress":
                        if !self.qInProgressArr.contains(ref){
                            self.qInProgressArr.append(ref)
                            controllerManager?.collectionVC.table.reloadData()
                        }
                        break
                    case "liked":
                        if !self.qCollectionArr.contains(ref){
                            self.qCollectionArr.append(ref)
                            controllerManager?.collectionVC.table.reloadData()
                        }
                        break
                    case "Concluded":
                        if !self.qConcludedArr.contains(ref) {
                            self.qConcludedArr.append(ref)
                        }
                    default:
                        break
                }
            }
        })
    }
    
    func getQuestion() -> FIRDatabaseReference?{
        if qMainArr.count < collectionMaxSize{
            networkingManager?.getQuestion(num: collectionMaxSize - qMainArr.count)
        }
        return qMainArr.popLast()
    }
    
    func getQuestion(with questionID: String) -> FIRDatabaseReference? {
        for qRef in qInProgressArr {
            if (getQuestionID(from: qRef) == questionID){
                return qRef
            }
        }
        for qRef in qCollectionArr {
            if (getQuestionID(from: qRef) == questionID) {
                return qRef
            }
        }
        for qRef in qConcludedArr {
            if (getQuestionID(from: qRef) == questionID) {
                return qRef
            }
        }
        return nil
    }
    
    func getQuestionID(from questionRef: FIRDatabaseReference) -> String {
        return questionRef.key
    }
}
