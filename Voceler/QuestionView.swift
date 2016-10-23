//
//  QuestionView.swift
//  Voceler
//
//  Created by 钟镇阳 on 10/1/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import GrowingTextViewHandler
import MJRefresh
import SFFocusViewLayout
import SCLAlertView
import SDAutoLayout

class QuestionView: UIView, UITableViewDelegate, UITableViewDataSource {

    
    // FieldVars
    @IBOutlet weak var titlebarHeight: NSLayoutConstraint!
    var handler:GrowingTextViewHandler!
    
    var liked = false{
        didSet{
            likeBtn?.setImage(img: liked ? #imageLiteral(resourceName: "star_filled") : #imageLiteral(resourceName: "star"), color: darkRed)
            if let question = currQuestion{
                currUser?.collectQuestion(QID: question.QID, like: liked)
            }
        }
    }
    
    var asker:UserModel?{
        didSet{
            if let asker = asker{
                if let img = asker.profileImg {
                    askerProfile.setImage(img, for: [])
                    askerProfile.imageView?.contentMode = .scaleAspectFill
                }
                else{
                    asker.loadProfileImg()
                    setAskerImg()
                }
            }
        }
    }
    
    // UIVars
    @IBOutlet weak var titleBarView: UIView!
    @IBOutlet weak var likeBtn: UIButton?
    @IBOutlet weak var detailTV: UITextView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var askerProfile: UIButton!
    @IBOutlet weak var askerLbl: UILabel!
    var currQuestion:QuestionModel!
    let tableView = UITableView()
    var pullUpMask = UILabel()
//    var collectionFooter:MJRefreshBackNormalFooter!
    var parent:UIViewController!
//    var focusLayout:SFFocusViewLayout!
    
    // Actions
    @IBAction func askerInfo(_ sender: AnyObject) {
        showUser(user: asker)
    }
    
    @IBOutlet weak var addOptionField: UITextField!
    
    @IBAction func likeAction(_ sender: AnyObject) {
        if parent is MainVC{
            if !liked && currUser!.qCollection.count >= currUser!.qInCollectionLimit{
                _ = SCLAlertView().showError("Sorry", subTitle: "You are only allowed to have up to \(currUser!.qInCollectionLimit) in collection. Please conclude a question.")
            }
            else{
                liked = !liked
            }
        }
        else if parent is InCollectionVC{
            liked = !liked
        }
    }
    
    // Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currQuestion.qOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptCell") as! OptCell
        cell.setup(option: currQuestion.qOptions[indexPath.row], questionView: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.isSelected = false
        if let cell = cell as? OptCell{
            cell.optLiked()
        }
    }
    
    func setAskerImg(){
        if let img = asker?.profileImg{
            askerProfile.setImage(img, for: [])
        }
        else if let askerId = asker?.uid{
            NotificationCenter.default.addObserver(self, selector: #selector(setAskerImg), name: NSNotification.Name(askerId + "profile"), object: nil)
        }
    }
    
    private func setQuestion(question:QuestionModel){
        currQuestion = question
        setDescription()
        if #available(iOS 10.0, *) {
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
                self.setDescription()
            }
        } else {
            // Fallback on earlier versions
            _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(setDescription), userInfo: nil, repeats: false)
        }
        tableView.isUserInteractionEnabled = true
        
        let oRef = question.qRef.child("options")
        oRef.observe(.childAdded, with: { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any>{
                let opt = OptionModel(question:question, ref: snapshot.ref, dict: dict)
                question.optArrAdd(option: opt)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                self.pullUpMask.isHidden = true
            }
        })
        
        asker = question.qAnonymous ? nil : UserModel.getUser(uid: question.qAskerID, getProfile: true)
        if let asker = asker{
            NotificationCenter.default.addObserver(forName: NSNotification.Name(asker.uid+"username"), object: nil, queue: nil, using: { (noti) in
                self.askerLbl.text = asker.username
            })
        }
        askerLbl.text = asker?.username
        pullUpMask.isHidden = question.qOptions.count > 0
        titlebarHeight.constant = 56
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 128
    }
    
    func showUser(user:UserModel?){
        if let user = user{
            // TODO
//            let vc = VC(name: "Profile", isNav: false, isCenter: false, isNew: true) as! ProfileVC
//            vc.thisUser = user
//            user.profileVC = vc
//            parent.navigationController?.pushViewController(vc, animated: true)
        }
        else{
            _ = SCLAlertView().showWarning("Sorry", subTitle: "Anonymous asker")
        }
    }
    
    private func setupUI() {
        parent.view.addSubview(self)
        _ = sd_layout().topSpaceToView(parent.view, 0)?.rightSpaceToView(parent.view, 0)?.leftSpaceToView(parent.view, 0)?.bottomSpaceToView(parent.view, 0)
        
        askerProfile.imageView?.contentMode = .scaleAspectFill

        _ = titleBarView.addBorder(edges: .bottom, colour: UIColor.gray, thickness: 1.5)
        handler = GrowingTextViewHandler(textView: self.detailTV, withHeightConstraint: self.heightConstraint)
        handler.updateMinimumNumber(ofLines: 0, andMaximumNumberOfLine: 5)
        askerProfile.board(radius: 20, width: 0, color: .white)
        likeBtn?.setImage(img: #imageLiteral(resourceName: "star"), color: darkRed)
    }
    
    func addOption(text:String){
        let opt = OptionModel(question: currQuestion, description: text, offerBy: (appSetting.isAnonymous) ? nil : currUser!.uid)
        currQuestion?.addOption(opt: opt)
        pullUpMask.isHidden = true
        currQuestion?.choose(val: opt.oRef.key)
    }
    
    func setDescription() {
        detailTV.isSelectable = true
        handler.setText(currQuestion?.qDescrption, withAnimation: true)
        detailTV.isSelectable = false
    }
    
    func setup(parent:UIViewController, question:QuestionModel) {
        self.parent = parent
        addSubview(tableView)
        _ = tableView.sd_layout().topSpaceToView(detailTV, 0)?.bottomSpaceToView(addOptionField, 0)?.leftSpaceToView(self, 0)?.rightSpaceToView(self, 0)
        setupUI()
        setupTable()
        setQuestion(question: question)
    }
    
    func setupTable(){
        tableView.board(radius: 0, width: 1, color: .black)
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "OptCell", bundle: nil), forCellReuseIdentifier: "OptCell")
    }
    
    // Override functions
    override func awakeFromNib() {
        super.awakeFromNib()
        if let _ = parent as? InProgressVC{
            likeBtn?.isHidden = true
        }
    }

}
