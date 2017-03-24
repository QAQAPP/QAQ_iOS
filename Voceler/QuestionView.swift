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

class QuestionView: UIView, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{
    // FieldVars
    //    @IBOutlet weak var titlebarHeight: NSLayoutConstraint!
    var handler:GrowingTextViewHandler!
    
    var liked = false{
        didSet{
            let mainVC = controllerManager!.mainVC!
            if mainVC.currView == self{
                mainVC.navigationItem.rightBarButtonItem?.image = liked ? #imageLiteral(resourceName: "star_filled-32") : #imageLiteral(resourceName: "star-32")
            }
            if let question = currQuestion{
                currUser?.collectQuestion(qid: question.qid, like: liked)
            }
        }
    }
    
    var asker:UserModel?
    
    // UIVars
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var detailTV: UITextView!
    var currQuestion:QuestionModel!
    //var optsView:UICollectionView!
    var optsView:UITableView!
    var pullUpMask = UILabel()
    
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
            _ = SCLAlertView().showError("Sorry", subTitle: "You are only allowed to have up to \(currUser!.qInCollectionLimit) in collection. Please conclude a question.")
        }
        else{
            liked = !liked
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return currQuestion.qOptions.count
        
    }
    
    var cellHeightArray = [CGFloat]()
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:OptViewTableCell = OptViewTableCell(style:UITableViewCellStyle.default, reuseIdentifier:"OptViewTableCell");
        cell.setup(option: currQuestion.qOptions[indexPath.row], questionView: self)
        cellHeightArray.append(40 + cell.textView.frame.height)
        return cell;
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as! OptViewTableCell).option = currQuestion?.qOptions[indexPath.row]
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
    
    private func setQuestion(){
        setDescription()
        optsView.isUserInteractionEnabled = true
        
        let oRef = currQuestion.qRef.child("options")
        oRef.observe(.childAdded, with: { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any>{
                let opt = OptionModel(question:self.currQuestion, ref: snapshot.ref, dict: dict)
                self.currQuestion.optArrAdd(option: opt)
                DispatchQueue.main.async {
                    self.optsView.reloadData()
                }
                self.pullUpMask.isHidden = true
            }
        })
        
        asker = currQuestion.qAnonymous ? nil : UserModel.getUser(uid: currQuestion.qAskerID, getProfile: true)
        if let asker = asker{
            NotificationCenter.default.addObserver(forName: NSNotification.Name(asker.uid+"username"), object: nil, queue: nil, using: { (noti) in
                
            })
        }
        pullUpMask.isHidden = currQuestion.qOptions.count > 0
        
        optsView.reloadData()
    }
    
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
        
        
        if parent is MainVC{
            let header = MJRefreshNormalHeader {
                controllerManager?.mainVC.nextContent()
            }
            header?.setTitle("Skip Question", for: .pulling)
            optsView.mj_header = header
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
        let option = OptionModel(question: currQuestion, description: text, offerBy: (appSetting.isAnonymous) ? nil : currUser!.uid)
        currQuestion?.addOption(opt: option)
        pullUpMask.isHidden = true
        optsView.reloadData()
    }
    
    func setDescription() {
        handler.setText(currQuestion!.qDescrption, animated: false)
    }
    
    var parent:UIViewController!{
        didSet{
            print(parent)
        }
    }
    func setup(parent:UIViewController) {
        self.parent = parent
        
        optsView = UITableView()
        optsView.backgroundColor = .white
        optsView.separatorStyle = .none
        
        setupUI()
        setupTable()
        setQuestion()
        self.addSubview(optsView)
        _ = optsView.sd_layout().topSpaceToView(detailTV, 0)?.bottomSpaceToView(addOptionField, 0)?.leftSpaceToView(self, 0)?.rightSpaceToView(self, 0)
        
    }
    
    func setupTable(){
        optsView.delegate = self
        optsView.dataSource = self
        optsView.isOpaque = false
        optsView.estimatedRowHeight = 1000.0
        optsView.rowHeight = UITableViewAutomaticDimension
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        addOptionField.endEditing(true)
    }
    
    // Override functions
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
