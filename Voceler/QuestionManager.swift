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
        databaseUserRef.child(currUser!.uid).child("Questions").observe(.childAdded, with: { (snapshot) in
            if let type = snapshot.value as? String{
                let ref = databaseQuestionRef.child(snapshot.key)
                switch type{
                    case "In progress":
                        if !self.qInProgressArr.contains(ref){
                            self.qInProgressArr.append(ref)
                        }
                        break
                    case "liked":
                        if !self.qCollectionArr.contains(ref){
                            self.qCollectionArr.append(ref)
                        }
                        break
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
}
