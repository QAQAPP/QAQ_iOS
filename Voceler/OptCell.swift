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
    var isLiked = false
    func optLiked(){
        let vc = controllerManager.mainVC
        if !isLiked{
            //        if let vc = self.parent.parent as? MainVC{
            likeBtn.setImage(img: #imageLiteral(resourceName: "like_filled"), color: pinkColor)
            let optRef = option.oRef
            question.choose(val: optRef!.ref.key)
            optRef?.child("val").runTransactionBlock({ (data) -> FIRTransactionResult in
                if let num = data.value as? Int{
                    data.value = num + 1
                }
                return FIRTransactionResult.success(withValue: data)
            })
            isLiked = true
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
    
    func setup(option:OptionModel, question:QuestionModel){
        self.question = question
        self.option = option
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
