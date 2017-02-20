//
//  NotificationModel.swift
//  QAQ
//
//  Created by Jiayang Miao on 2/14/17.
//  Copyright © 2017 Zhenyang Zhong. All rights reserved.
//

import UIKit

enum NotificationType {
    case questionAnswered
    case questionViewed
    case answerChosen
    //case questionLiked
}

class NotificationModel: NSObject {

    let qid:String
    let viewed:Bool
    let type:NotificationType
    
    //let details:NSObject - versatile helper object used to store user information/option information
    let details:String // Alternative implementation using just string
    
    override init () {
        self.qid = "0"
        self.viewed = false
        self.type = NotificationType.questionAnswered
        self.details = "0"
    }
    
    init (_ qid: String, of type: NotificationType, with details: NSObject) {
        self.qid = qid
        self.viewed = false
        self.type = type
        
        // Setup details - need more work
        switch type {
        case NotificationType.questionAnswered:
         // by whom
         self.details = "WN0ROkKZmwTddhqy3ENipoT77Qh1"
            
        case NotificationType.questionViewed:
         // how many times
         self.details = "100"
            
        case NotificationType.answerChosen:
         // by whom
         self.details = "WN0ROkKZmwTddhqy3ENipoT77Qh1"
            
        }
    }
}
