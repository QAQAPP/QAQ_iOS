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
    case questionConcluded
    //case questionLiked
}

class NotificationModel: NSObject {

    let qid:String
    let viewed:Bool
    let type:NotificationType
    let timestamp:String
    
    //let details:NSObject - versatile helper object used to store user information/option information
    let details:String // Alternative implementation using just string
    
    override init () {
        self.qid = "0"
        self.viewed = false
        self.type = NotificationType.questionAnswered
        self.details = "0"
        self.timestamp = "200706290000000"
    }
    
    init (_ qid: String, of type: NotificationType, with details: AnyObject, whether viewed: Bool = false, on time: String) {
        self.qid = qid
        self.viewed = viewed
        self.type = type
        self.timestamp = time
        
        // Setup details - hard code for now
        switch type {
        case NotificationType.questionAnswered:
         // by whom
         self.details = details as! String
            
        case NotificationType.questionViewed:
         // how many times
         self.details = (details as! NSNumber).stringValue
            
        case NotificationType.questionConcluded:
         // by whom
         self.details = details as! String
        }
    }
}
