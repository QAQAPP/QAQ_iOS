//
//  OptViewTableCell.swift
//  QAQ
//
//  Created by ERIC on 2/13/17.
//  Copyright © 2017 Zhenyang Zhong. All rights reserved.
//

import UIKit
import SDAutoLayout
import FirebaseDatabase
import SCLAlertView
import LTMorphingLabel
import GrowingTextViewHandler_Swift

class OptViewTableCell: UITableViewCell{
    
    var textView = UITextView()
    var bgColorView = UIView()
    var profileImg = UIButton()
    var topPadding = UIView()
    var likeBtn = UIButton()
    let numLikeLbl = UILabel()
    var usrName = String()
//    var handler:GrowingTextViewHandler!
    var heightConst:NSLayoutConstraint!
    
    let OPTIONS_TEXT_FONT = "Avenir-Roman"
    let OPTIONS_TEXT_FONT_SIZE:CGFloat = 17
    let OPTIONS_TEXT_FONT_COLOR_SELECTED = 0xFFFFFF
    let OPTIONS_TEXT_FONT_COLOR_DESELECTED = 0x858585

    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        bgColorView.backgroundColor = UIColor(netHex: 0xF3A64B)
        self.selectedBackgroundView = bgColorView
        // Configure the view for the selected state
    }
    
    func showProfile(){
        questionView.parent.show(controllerManager!.getUserVC(ref: databaseUserRef.child(option.oOfferBy)), sender: self)
    }
    
    func setUpUI(){
        
        textView.font = UIFont(name: OPTIONS_TEXT_FONT, size: OPTIONS_TEXT_FONT_SIZE)
        textView.textColor = UIColor(netHex: OPTIONS_TEXT_FONT_COLOR_DESELECTED)
        textView.isUserInteractionEnabled = false
        textView.isEditable = false
        textView.isScrollEnabled = false

        numLikeLbl.font = UIFont(name: OPTIONS_TEXT_FONT, size: OPTIONS_TEXT_FONT_SIZE)
        numLikeLbl.textColor = UIColor(netHex: OPTIONS_TEXT_FONT_COLOR_DESELECTED)
        
        self.contentView.addSubview(textView)
        self.contentView.addSubview(profileImg)
        self.contentView.addSubview(likeBtn)
        self.contentView.addSubview(numLikeLbl)

        
        _ = profileImg.sd_layout().heightIs(32)?.widthIs(32)?.leftSpaceToView(contentView, 8)?.topSpaceToView(self.contentView, 8)
        _ = likeBtn.sd_layout().heightIs(24)?.widthIs(24)?.rightSpaceToView(contentView, 8)?.bottomSpaceToView(contentView, 4)
        _ = numLikeLbl.sd_layout().heightIs(24)?.widthIs(32)?.rightSpaceToView(likeBtn, 8)?.centerYEqualToView(likeBtn)
        _ = textView.sd_layout().topSpaceToView(self.contentView,4)?.leftSpaceToView(self.profileImg, 8)?.rightSpaceToView(self.numLikeLbl, 4)?.bottomSpaceToView(self.contentView, 8)
        numLikeLbl.textAlignment = .right
        
        let fixedWidth:CGFloat = UIScreen.main.bounds.width - 128
        print(fixedWidth)
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: 9999))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame;
        print(newFrame)

        profileImg.addTarget(self, action: #selector(showProfile), for: .touchUpInside)
    }

    func optLiked(){
        if questionView.parent is MainVC{
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (timer) in
                controllerManager?.mainVC.nextContent()
            })
            questionView.isUserInteractionEnabled = false
            question.userChoosed = true
            if !option.isLiked{
//                likeBtn.setImage(#imageLiteral(resourceName: "check_checked"), for: .normal)
                if questionView.parent is MainVC{
//                    for opt in question.qOptions{
//                        if opt == option && !opt.isLiked{
                            option.isLiked = true
//                        }
//                        else if opt.isLiked{
//                            opt.isLiked = false
//                        }
//                    }
                }
            }
        }
        else if let inProgressVC = questionView.parent as? InProgressVC, question.qAskerID == currUser!.ref.key{
            let alert = SCLAlertView()
            alert.addButton("Sure", action: {
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (timer) in
                    inProgressVC.afterConclude()
                    self.question.conclude(oid: self.option.oRef.key)
                })
                self.questionView.isUserInteractionEnabled = false
                self.question.userChoosed = true
                if !self.option.isLiked{
//                    self.likeBtn.setImage(#imageLiteral(resourceName: "check_checked"), for: .normal)
                    if self.questionView.parent is MainVC{
//                        for opt in self.question.qOptions{
//                            if opt == self.option && !opt.isLiked{
                                self.option.isLiked = true
//                            }
//                            else if opt.isLiked{
//                                opt.isLiked = false
//                            }
//                        }
                    }
                }
            })
            alert.showWarning("Conclusion", subTitle: "Are you sure it is a good answer?", closeButtonTitle: "Nope")
        }
        else{
            return
        }
    }
    
    func likeAction(sender: UIButton){
        optLiked()
    }
    
    func selected(){
        textView.textColor = UIColor(netHex: OPTIONS_TEXT_FONT_COLOR_SELECTED)
        likeBtn.setImage(#imageLiteral(resourceName: "check_checked"), for: .normal)
    }
    
    func deselected(){
        textView.textColor = UIColor(netHex: OPTIONS_TEXT_FONT_COLOR_DESELECTED)
        likeBtn.setImage(#imageLiteral(resourceName: "check"), for: .normal)
    }

    
    var option:OptionModel!{
        didSet{
            option.optionViewTableCell = self
//            textView.text = option.oDescription
//            if let uid = option.oOfferBy{
//                offerer = UserModel.getUser(uid: uid, getProfile: true)
//                setProfile()
//            }
//            self.option.oRef.child("val").observe(.value, with: { (snapshot) in
//                DispatchQueue.main.async {
//                    if let num = snapshot.value as? Int{
//                        self.setNumLikes(num: num)
//                    }
//                }
//            })
        }
    }
    
    func setNumLikes(num:Int){
        numLikeLbl.text = "\(num)"
    }
    
    var question:QuestionModel!
    var questionView:QuestionView!
    
    func setup(option:FIRDatabaseReference, questionView:QuestionView){
        self.profileImg.board(radius: 16, width: 0, color: .lightGray)
        self.profileImg.clipsToBounds = true
        
        self.questionView = questionView
        self.question = questionView.currQuestion
        self.profileImg.imageView?.contentMode = .scaleAspectFill
        self.option = OptionModel(optCell: self)
        self.option.setRef(ref: option)
        setUpUI()
        likeBtn.setImage(#imageLiteral(resourceName: "check"), for: .normal)
        likeBtn.addTarget(self, action: #selector(self.likeAction(sender:)), for: .touchUpInside)
    }
    
//    func setProfile(){
//        profileImg.tintColor = .clear
//        if let img = offerer?.profileImg{
//            profileImg.setImage(img, for: [])
//            profileImg.imageView?.contentMode = .scaleAspectFill
//        }
//        else if let uid = offerer?.uid{
//            NotificationCenter.default.addObserver(self, selector: #selector(setProfile), name: NSNotification.Name(uid + "profile"), object: nil)
//        }
//    }
}
