//
//  QuestionView.swift
//  Voceler
//
//  Created by 钟镇阳 on 10/1/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import GrowingTextViewHandler_Swift
import MJRefresh
import SFFocusViewLayout
import SCLAlertView
import SDAutoLayout
import IQKeyboardManagerSwift
import FirebaseDatabase

class QuestionView: UIView, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{
    // FieldVars
    //    @IBOutlet weak var titlebarHeight: NSLayoutConstraint!
    
    @IBOutlet weak var userBtn: UIButton!
    @IBAction func showProfile(_ sender: Any) {
//        if let asker = asker{
//            let vc = controllerManager!.getUserVC(user: asker)
//            self.parent.navigationController?.pushViewController(vc, animated: true)
//        }
//        else{
//            SCLAlertView().showWait("Loading", subTitle: "Loading user info.", duration: 2)
//        }
    }
//    func setProfile(){
//        userBtn.imageView?.tintColor = .clear
//        userBtn.board(radius: 16, width: 0, color: .clear)
//        if let img = asker?.profileImg{
//            userBtn.setImage(img, for: [])
//            userBtn.imageView?.contentMode = .scaleAspectFill
//        }
//        else if let uid = asker?.uid{
//            NotificationCenter.default.addObserver(self, selector: #selector(setProfile), name: NSNotification.Name(uid + "profile"), object: nil)
//        }
//    }
    @IBOutlet weak var username: UILabel!
    
    var handler:GrowingTextViewHandler!
    
    var liked = false{
        didSet{
            let mainVC = controllerManager!.mainVC!
            if mainVC.currView == self{
                mainVC.navigationItem.rightBarButtonItem?.image = liked ? #imageLiteral(resourceName: "star_filled-32") : #imageLiteral(resourceName: "star-32")
            }
            if let question = currQuestion{
                currUser?.collectQuestion(qid: question.qRef.key, like: liked)
            }
        }
    }
    
    // UIVars
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var detailTV: UITextView!
//    var questionRef:FIRDatabaseReference!{
//        didSet{
//            
//        }
//    }
    var currQuestion:QuestionModel!
    //var optsView:UICollectionView!
    var optsView:UITableView!
    let noAnswerView = UIImageView(image: #imageLiteral(resourceName: "no_answer"))
    
    // font and sizes
    let QUESTION_TEXT_FONT = "Avenir-Black"
    let QUESTION_TEXT_FONT_SIZE:CGFloat = 27
    let QUESTION_TEXT_FONT_COLOR = 0x50575D
    
    
    // Actions
    
    @IBAction func postAction(_ sender: Any) {
        postOption()
    }
    
    func postOption(){
        endEditing(true)
        if let text = addOptionField.text, !text.isEmpty{
            addOption(text: text)
            addOptionField.text = ""
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (timer) in
                controllerManager?.mainVC.nextContent()
            })
        }
    }
    
    @IBOutlet weak var addOptionField: UITextField!
    
    // Functions
    
    func likeQuestion(){
        if !liked && currUser!.qCollection.count >= currUser!.qInCollectionLimit!{
            _ = SCLAlertView().showError("Sorry", subTitle: "You are only allowed to have up to \(String(describing: currUser!.qInCollectionLimit)) in collection. Please conclude a question.")
        }
        else{
            liked = !liked
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        noAnswerView.isHidden = currQuestion.qOptions.count > 0
        if !noAnswerView.isHidden && currQuestion.qOptions.count > 0{
            UIView.animate(withDuration: 0.5, animations: {
                self.noAnswerView.alpha = 0
            }, completion: { (finished) in
                self.noAnswerView.isHidden = finished
            })
        }
        return currQuestion.qOptions.count
        
    }
    
    var cellHeightArray = [CGFloat]()
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:OptViewTableCell = OptViewTableCell(style:UITableViewCellStyle.default, reuseIdentifier:"OptViewTableCell");
        cell.profileImg.setImage(#imageLiteral(resourceName: "user-50"), for: .normal)
        cell.setup(option: currQuestion.qOptions[indexPath.row], questionView: self)
        cellHeightArray.append(16 + cell.textView.frame.height)
        return cell;
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        (cell as! OptViewTableCell).option = currQuestion?.qOptions[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = optsView.cellForRow(at: indexPath) as! OptViewTableCell
        cell.optLiked()
        cell.isSelected = false
    }
    
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        let cell = optsView.cellForRow(at: indexPath) as! OptViewTableCell
//        cell.deselected()
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row >= cellHeightArray.count ? 600 : cellHeightArray[indexPath.row]
    }
    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
    
    
    func nextContent(){
        controllerManager?.mainVC.nextContent()
    }
    
//    private func setQuestion(){
//        setDescription()
//        asker = UserModel.getUser(uid: currQuestion.qAskerID, getProfile: true)
//        if let asker = asker{
//            setProfile()
//            asker.ref.child("username").observe(.value, with: { (snapshot) in
//                if let name = snapshot.value as? String{
//                    self.username.text = name
//                }
//            })
//            NotificationCenter.default.addObserver(forName: NSNotification.Name(asker.uid+"username"), object: nil, queue: nil, using: { (noti) in
//                
//            })
//        }
//    }
    
    func showUser(user:UserModel?){
        if let user = user, let vc = controllerManager?.getUserVC(user: user){
            parent.navigationController?.pushViewController(vc, animated: true)
        }
        else{
            _ = SCLAlertView().showWarning("Sorry", subTitle: "Anonymous asker")
        }
    }
    
    private func setupUI() {
        
        //set question text view's font size and color
        
        self.detailTV.font = UIFont(name: QUESTION_TEXT_FONT, size: QUESTION_TEXT_FONT_SIZE)
        self.detailTV.textColor = UIColor(netHex: QUESTION_TEXT_FONT_COLOR)
        
        addOptionField.board(radius: 16, width: 1, color: themeColor)
        addOptionField.attributedPlaceholder = NSAttributedString(string: "Add an option", attributes:[NSForegroundColorAttributeName: themeColor])
        addOptionField.delegate = self
        addOptionField.returnKeyType = .send
        handler = GrowingTextViewHandler(textView: self.detailTV, heightConstraint: self.heightConstraint)
        handler.minimumNumberOfLines = 0
        handler.maximumNumberOfLines = 5
        userBtn.imageView?.tintColor = .clear
        userBtn.imageView?.contentMode = .scaleAspectFill
        userBtn.board(radius: 16, width: 0, color: .clear)
        
        if parent is MainVC{
            let header = MJRefreshNormalHeader {
                controllerManager?.mainVC.nextContent()
            }
            header?.setTitle("Skip Question", for: .pulling)
            optsView.mj_header = header
//			IQKeyboardManager.sharedManager().disabledToolbarClasses = [parent]
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == addOptionField{
            postOption()
        }
        return true
    }
    
    func addOption(text:String){
        currQuestion.userChoosed = true
        OptionModel.postPotion(question: currQuestion.qRef, description: text, offerBy: currQuestion!.qAskerID)
//        currQuestion?.addOption(opt: option)
//        cellHeightArray.removeAll()
//        optsView.reloadData()
    }
    
    func setDescription() {
        handler.setText(currQuestion!.qDescrption, animated: false)
    }
    
    var parent:UIViewController!{
        didSet{
            print(parent)
        }
    }
    func setup(parent:UIViewController, qRef:FIRDatabaseReference) {
        self.currQuestion = QuestionModel(ref: qRef, questionView: self)
        self.parent = parent
        touchToHideKeyboard()
        optsView = UITableView()
        optsView.backgroundColor = .white
        optsView.separatorStyle = .none
        
        setupUI()
//        setQuestion()
        setupTable()
        lazyLoading()
    }
    
    func lazyLoading(){
        username.text = currQuestion.askerName
        userBtn.setImage(currQuestion.askerImg, for: .normal)
        handler.setText(currQuestion.qDescrption, animated: true)
        optsView.reloadData()
    }
    
    func setupTable(){
        optsView.delegate = self
        optsView.dataSource = self
        optsView.isOpaque = false
        optsView.estimatedRowHeight = 1000.0
        optsView.rowHeight = UITableViewAutomaticDimension
        self.addSubview(optsView)
        _ = optsView.sd_layout().topSpaceToView(detailTV, 0)?.bottomSpaceToView(addOptionField, 0)?.leftSpaceToView(self, 0)?.rightSpaceToView(self, 0)
        
        noAnswerView.contentMode = .scaleAspectFit
        noAnswerView.touchToHideKeyboard()
        self.addSubview(noAnswerView)
        _ = noAnswerView.sd_layout().topSpaceToView(detailTV, 0)?.bottomSpaceToView(addOptionField, 0)?.leftSpaceToView(self, 64)?.rightSpaceToView(self, 64)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        addOptionField.endEditing(true)
    }
    
    // Override functions
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
