//
//  ContentVC.swift
//  QAQ
//
//  Created by 钟镇阳 on 10/22/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import SCLAlertView

class ContentVC: UIViewController {
    var contentView : UIView!
    var alertShowed = false
    
    func upvote(){
        if let questionView = contentView as? QuestionView{
            if !questionView.currQuestion.userChoosed && !questionView.liked && !alertShowed{
                alertShowed = true
                let alert = SCLAlertView()
                _ = alert.addButton("Yes", action: {
                    questionView.likeQuestion()
                })
                _ = alert.showNotice("Upvote", subTitle: "Do you want to upvote this question?")
            }
            questionView.currQuestion.choose()
        }
    }
}
