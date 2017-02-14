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

class OptViewTableCell: UITableViewCell{
//    @IBOutlet weak var textView: UITextView!
//    @IBOutlet weak var controlView: UIView!
//    @IBOutlet weak var profileImg: UIButton!
//    @IBOutlet weak var nameLbl: UILabel!
    
    var textView = UITextView()
    var profileImg = UIButton()
    var topPadding = UIView()
    var bottomPadding = UIView()
    var likeBtn = UIButton()
    var usrName = String()
    
    let OPTIONS_TEXT_FONT = "Avenir-Roman"
    let OPTIONS_TEXT_FONT_SIZE:CGFloat = 17
    let OPTIONS_TEXT_FONT_COLOR_SELECTED = 0xFFFFFF
    let OPTIONS_TEXT_FONT_COLOR_DESELECTED = 0x858585
    
    
//    //TODO: commit test
//    @IBAction func moreAction(_ sender: AnyObject) {
//        let vc = UIViewController()
//        let textView = UITextView()
//        textView.text = option.oDescription
//        textView.isSelectable = false
//        textView.isEditable = false
//        _ = textView.sd_layout().topSpaceToView(vc.view, 0)?.bottomSpaceToView(vc.view, 0)?.leftSpaceToView(vc.view, 0)?.rightSpaceToView(vc.view, 0)
//        vc.view.addSubview(textView)
//        questionView.parent.navigationController?.pushViewController(vc, animated: true)
//    }
//    
//    @IBOutlet weak var likeBtn: UIButton!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //self.frame = CGRect(x: 0, y: 0, width: 375, height: 120)
        setUpUI()
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profileImg.board(radius: profileImg.width/2, width: 0, color: .lightGray)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setUpUI(){
        
        textView.font = UIFont(name: OPTIONS_TEXT_FONT, size: OPTIONS_TEXT_FONT_SIZE)
        textView.textColor = UIColor(netHex: OPTIONS_TEXT_FONT_COLOR_DESELECTED)
        textView.sizeToFit()
        textView.isUserInteractionEnabled = false
        
        topPadding.backgroundColor = UIColor.white
        bottomPadding.backgroundColor = UIColor.white
        //self.addSubview(topPadding)
        //self.addSubview(bottomPadding)
        self.addSubview(textView)
        self.addSubview(profileImg)
        self.addSubview(likeBtn)
        //_ = topPadding.sd_layout().topEqualToView(self)?.heightIs(15)?.leftEqualToView(self)?.rightEqualToView(self)
        //_ = bottomPadding.sd_layout().heightIs(15)?.bottomEqualToView(self)?.leftEqualToView(self)?.rightEqualToView(self)
        _ = textView.sd_layout().topEqualToView(self)?.leftSpaceToView(self, 64)?.rightSpaceToView(self, 32)
        _ = profileImg.sd_layout().heightIs(31)?.widthIs(31)?.centerXIs(30)?.centerYEqualToView(textView)
        _ = likeBtn.sd_layout().heightIs(23)?.widthIs(23)?.centerXIs(350)?.centerYEqualToView(textView)
       
        
        //self.setupAutoHeight(withBottomView: textView, bottomMargin: 15)
        
    }

    func optLiked(){
        if questionView.parent is MainVC{
            question.userChoosed = true
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
                questionView.optsView.reloadData()
            }
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (timer) in
                controllerManager?.mainVC.nextContent()
            })
        }
    }
    
//    
//    @IBAction func likeAction(_ sender: AnyObject) {
//        optLiked()
//    }
//    
//    @IBOutlet weak var numLikeLbl: UILabel!
//    
//    @IBAction func showProfile(_ sender: Any) {
//        if let user = offerer, let vc = controllerManager?.profileVC(user: user){
//            questionView.parent.navigationController?.pushViewController(vc, animated: true)
//        }
//        else{
//            _ = SCLAlertView().showWarning("Sorry", subTitle: "Anonymous asker")
//        }
//    }
    
    func selected(){
        //change background color to orange
        self.backgroundColor = UIColor(netHex: 0xF3A64B)
        textView.textColor = UIColor(netHex: OPTIONS_TEXT_FONT_COLOR_SELECTED)
    }
    
    func deselected(){
        //change background color to orange
        self.backgroundColor = UIColor.white
        textView.textColor = UIColor(netHex: OPTIONS_TEXT_FONT_COLOR_DESELECTED)
    }

    
    var option:OptionModel!{
        didSet{
            textView.text = option.oDescription
            print(option.oDescription)
            if let uid = option.oOfferBy{
                offerer = UserModel.getUser(uid: uid, getProfile: true)
                setProfile()
                
//                
//                usrName.text = "Anonym"
//                nameLbl.textColor = .gray
//                NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: uid+"username"), object: nil, queue: nil, using: { (noti) in
//                    if let username = self.offerer?.username{
//                        self.nameLbl.text = username
//                        self.nameLbl.textColor = .black
//                    }
//                })
            }
//            self.option.oRef.child("val").observe(.value, with: { (snapshot) in
//                DispatchQueue.main.async {
//                    if let num = snapshot.value as? Int{
//                        self.setNumLikes(num: num)
//                    }
//                }
//            })
        }
    }
    
//    func setNumLikes(num:Int){
//        if question.userChoosed && question.qAskerID != currUser?.uid{
//            numLikeLbl.text = "\(num)"
//        }
//        else{
//            numLikeLbl.text = "--"
//        }
//    }
//    
    var offerer:UserModel?
    var question:QuestionModel!
    var questionView:QuestionView!
    
    func setup(option:OptionModel, questionView:QuestionView){
        self.questionView = questionView
        self.question = questionView.currQuestion
        self.option = option
        likeBtn.setImage(img: option.isLiked ? #imageLiteral(resourceName: "like_filled") : #imageLiteral(resourceName: "like"), color: pinkColor)
        //controlView.backgroundColor = themeColor
        //        board(radius: 0, width: 1, color: themeColor)
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
    
//    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
//        super.apply(layoutAttributes)
//        
//    }
}
