//
//  OptCell.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 6/27/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import SDAutoLayout
import FirebaseDatabase

class OptCell: UITableViewCell{
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var profileImg: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    @IBAction func moreAction(_ sender: AnyObject) {
    }
    @IBOutlet weak var likeBtn: UIButton!
//    var isLiked = false{
//        didSet{
//            let optRef = option.oRef
//            likeBtn.setImage(img: isLiked ? #imageLiteral(resourceName: "like_filled") : #imageLiteral(resourceName: "like"), color: pinkColor)
//            if isLiked{
//                question.choose(val: optRef!.ref.key)
//                optRef?.child("val").runTransactionBlock({ (data) -> FIRTransactionResult in
//                    if let num = data.value as? Int{
//                        data.value = num + 1
//                    }
//                    return FIRTransactionResult.success(withValue: data)
//                })
//            }
//            else{
//                optRef?.child("val").runTransactionBlock({ (data) -> FIRTransactionResult in
//                    if let num = data.value as? Int{
//                        data.value = num - 1
//                    }
//                    return FIRTransactionResult.success(withValue: data)
//                })
//            }
//        }
//    }
    func optLiked(){
        let vc = controllerManager?.mainVC
        if !option.isLiked{
            likeBtn.setImage(img: #imageLiteral(resourceName: "like_filled"), color: pinkColor)
            for opt in question.qOptions{
                if opt == option && !opt.isLiked{
                    opt.isLiked = true
                }
                else if opt.isLiked{
                    opt.isLiked = false
                }
            }
            questionVIew.tableView.reloadData()
        }
        vc?.nextContent()
        //        }
        //        else if let vc = self.parent.parent as? InProgressVC{
        //            likeBtn.setImage(img: #imageLiteral(resourceName: "like_filled"), color: pinkColor)
        //            vc.conclude(OID: self.option.oRef.key, cell: self)
        //        }
        //        else if self.parent.parent is InCollectionVC{
        //            _ = SCLAlertView().showWarning("Warning", subTitle: "You cannot modify the question in collection")
        //        }
    }
    
    func cancelLike(){
        if option.isLiked{
            option.isLiked = false
            likeBtn.setImage(img: #imageLiteral(resourceName: "like"), color: pinkColor)
        }
    }
    
    @IBAction func likeAction(_ sender: AnyObject) {
        optLiked()
    }
    
    @IBOutlet weak var numLikeLbl: UILabel!
    
    var option:OptionModel!{
        didSet{
            textView.text = option.oDescription
            setNumLikes(num: option.oVal)
            if let uid = option.oOfferBy{
                offerer = UserModel.getUser(uid: uid, getProfile: true)
                setProfile()
                nameLbl.text = "Anonym"
                nameLbl.textColor = .gray
                NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: uid+"username"), object: nil, queue: nil, using: { (noti) in
                    if let username = self.offerer?.username{
                        self.nameLbl.text = username
                        self.nameLbl.textColor = .black
                    }
                })
            }
            option.oRef.child("val").observe(.value, with: { (snapshot) in
                DispatchQueue.main.async {
                    if let num = snapshot.value as? Int{
                        self.setNumLikes(num: num)
                    }
                }
            })
        }
    }
    
    func setNumLikes(num:Int){
        numLikeLbl.text = "\(num)"
    }
    
    var offerer:UserModel?
    var question:QuestionModel!
    var questionVIew:QuestionView!
    
    func setup(option:OptionModel, questionView:QuestionView){
        self.questionVIew = questionView
        self.question = questionView.currQuestion
        self.option = option
        likeBtn.setImage(img: option.isLiked ? #imageLiteral(resourceName: "like_filled") : #imageLiteral(resourceName: "like"), color: pinkColor)
    }
    
    func setProfile(){
        profileImg.tintColor = .clear
        if let img = offerer?.profileImg{
            profileImg.setImage(img, for: [])
            profileImg.imageView?.contentMode = .scaleAspectFill
        }
        else if let uid = offerer?.uid{
            NotificationCenter.default.addObserver(self, selector: #selector(setProfile), name: NSNotification.Name(uid + "profile"), object: nil)
        }
    }
}
