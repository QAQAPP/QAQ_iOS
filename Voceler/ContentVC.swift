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
    
    func profileTapped(){
        controllerManager?.mainVC.showInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let vc = controllerManager?.mainVC
        let item = vc?.navigationItem
        item?.leftBarButtonItem?.tintColor = .white
        if let view = contentView as? QuestionView{
            vc?.likeBtn.image = view.liked ? #imageLiteral(resourceName: "star_filled-32") : #imageLiteral(resourceName: "star-32")
            item?.setRightBarButton(vc?.likeBtn, animated: true)
            if let image = view.asker?.profileImg{
                item?.leftBarButtonItem?.image = nil
                let imageView = UIImageView(image: image.withRenderingMode(.alwaysOriginal))
                imageView.contentMode = .scaleAspectFill
                imageView.width = 32
                imageView.height = 32
                imageView.board(radius: imageView.width/2, width: 0, color: .clear)
                let tap = UITapGestureRecognizer(target: self, action: #selector(profileTapped))
                imageView.addGestureRecognizer(tap)
                item?.leftBarButtonItem?.customView = imageView
            }
            else{
                item?.leftBarButtonItem?.image = #imageLiteral(resourceName: "user_male_circle-32")
            }
        }
        else{
            item?.setRightBarButton(nil, animated: true)
            if let image = currUser?.profileImg{
                item?.leftBarButtonItem?.image = image.resizedImage(to: CGSize(width: 32, height: 32))
            }
            else{
                item?.leftBarButtonItem?.image = #imageLiteral(resourceName: "user_male_circle-32")
            }
        }
    }
}
