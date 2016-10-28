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
import SCLAlertView
import LTMorphingLabel

class OptCell: UICollectionViewCell{
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var profileImg: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    @IBAction func moreAction(_ sender: AnyObject) {
    }
    @IBOutlet weak var likeBtn: UIButton!
    
    func optLiked(){
        question.userChoosed = true
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
            questionVIew.optsView.reloadData()
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profileImg.board(radius: profileImg.width/2, width: 0, color: .lightGray)
    }
    
    var option:OptionModel!{
        didSet{
            textView.text = option.oDescription
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
            self.option.oRef.child("val").observe(.value, with: { (snapshot) in
                DispatchQueue.main.async {
                    if let num = snapshot.value as? Int{
                        self.setNumLikes(num: num)
                    }
                }
            })
        }
    }
    
    func setNumLikes(num:Int){
        if question.userChoosed{
            numLikeLbl.text = "\(num)"
        }
        else{
            numLikeLbl.text = "--"
        }
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
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
    }
}
