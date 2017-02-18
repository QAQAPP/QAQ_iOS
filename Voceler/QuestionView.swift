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

class QuestionView: UIView, UICollectionViewDataSource, UICollectionViewDelegate{
    // FieldVars
//    @IBOutlet weak var titlebarHeight: NSLayoutConstraint!
    var handler:GrowingTextViewHandler!
    
    var liked = false{
        didSet{
            let mainVC = controllerManager!.mainVC!
            if mainVC.currView == self{
                mainVC.navigationItem.rightBarButtonItem?.image = liked ? #imageLiteral(resourceName: "star_filled-32") : #imageLiteral(resourceName: "star-32")
                print(liked)
            }
            if let question = currQuestion{
                currUser?.collectQuestion(QID: question.QID, like: liked)
            }
        }
    }
    
    var asker:UserModel?
    
    // UIVars
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var detailTV: UITextView!
    var currQuestion:QuestionModel!
    var optsView:UICollectionView!
    var pullUpMask = UILabel()
    
    // Actions
    
//    @IBAction func postAction(_ sender: Any) {
//        endEditing(true)
//        if let text = addOptionField.text, !text.isEmpty{
//            addOption(text: text)
//            addOptionField.text = ""
//            controllerManager?.mainVC.nextContent()
//        }
//    }
    
    @IBOutlet weak var addOptionField: UITextField!
    
    // Functions
    func likeQuestion(){
        if !liked && currUser!.qCollection.count >= currUser!.qInCollectionLimit{
            _ = SCLAlertView().showError("Sorry", subTitle: "You are only allowed to have up to \(currUser!.qInCollectionLimit) in collection. Please conclude a question.")
        }
        else{
            liked = !liked
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currQuestion.qOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OptCell", for: indexPath) as! OptCell
        cell.setup(option: currQuestion.qOptions[indexPath.row], questionView: self)
        return cell
    }
    
    @objc(collectionView:willDisplayCell:forItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        (cell as! OptCell).option = currQuestion?.qOptions[indexPath.row]
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let focusViewLayout = collectionView.collectionViewLayout as? SFFocusViewLayout else {
            fatalError("error casting focus layout from collection view")
        }
        
        let offset = focusViewLayout.dragOffset * CGFloat(indexPath.item)
        if collectionView.contentOffset.y != offset {
            collectionView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
        }
        let cell = optsView.cellForItem(at: indexPath)
        cell?.isSelected = false
        if let cell = cell as? OptCell{
            cell.optLiked()
            collectionView.isUserInteractionEnabled = false
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (timer) in
                controllerManager?.mainVC.nextContent()
            })
        }
    }
    func nextContent(){
        controllerManager?.mainVC.nextContent()
    }
    
    private func setQuestion(question:QuestionModel){
        currQuestion = question
        setDescription()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
            self.setDescription()
        }
        optsView.isUserInteractionEnabled = true
        
        let oRef = question.qRef.child("options")
        oRef.observe(.childAdded, with: { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any>{
                let opt = OptionModel(question:question, ref: snapshot.ref, dict: dict)
                question.optArrAdd(option: opt)
                DispatchQueue.main.async {
                    self.optsView.reloadData()
                }
                self.pullUpMask.isHidden = true
            }
        })
        
        asker = question.qAnonymous ? nil : UserModel.getUser(uid: question.qAskerID, getProfile: true)
        if let asker = asker{
            NotificationCenter.default.addObserver(forName: NSNotification.Name(asker.uid+"username"), object: nil, queue: nil, using: { (noti) in
                
            })
        }
        pullUpMask.isHidden = question.qOptions.count > 0
        
        optsView.reloadData()
    }
    
    func showUser(user:UserModel?){
        if let user = user, let vc = controllerManager?.profileVC(user: user){
            parent.navigationController?.pushViewController(vc, animated: true)
        }
        else{
            _ = SCLAlertView().showWarning("Sorry", subTitle: "Anonymous asker")
        }
    }
    
    private func setupUI() {
        addOptionField.board(radius: 16, width: 1, color: themeColor)
        addOptionField.attributedPlaceholder = NSAttributedString(string: "Add an option", attributes:[NSForegroundColorAttributeName: themeColor])
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
    
    func addOption(text:String){
        currQuestion.userChoosed = true
        let option = OptionModel(question: currQuestion, description: text, offerBy: (appSetting.isAnonymous) ? nil : currUser!.uid)
        currQuestion?.addOption(opt: option)
        pullUpMask.isHidden = true
        currQuestion?.choose(val: option.oRef.key)
        let indexPath = IndexPath(row: currQuestion.qOptions.count, section: 0)
        optsView.delegate?.collectionView!(optsView, didSelectItemAt: indexPath)
    }
    
    func setDescription() {
        handler.setText(currQuestion!.qDescrption, animated: true)
    }
    
    var parent:UIViewController!
    func setup(parent:UIViewController, question:QuestionModel) {
        self.parent = parent
        let focusLayout = SFFocusViewLayout()
        focusLayout.standardHeight = 128
        focusLayout.focusedHeight = 200
        focusLayout.dragOffset = 100
        optsView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 100, height: 110), collectionViewLayout: focusLayout)
        optsView.backgroundColor = .white
        addSubview(optsView)
        _ = optsView.sd_layout().topSpaceToView(detailTV, 0)?.bottomSpaceToView(addOptionField, 0)?.leftSpaceToView(self, 0)?.rightSpaceToView(self, 0)
        setupUI()
        setupTable()
        setQuestion(question: question)
    }
    
    func setupTable(){
//        optsView.board(radius: 0, width: 1, color: .black)
        optsView.delegate = self
        optsView.dataSource = self
        let nibName = UINib(nibName: "OptCell", bundle:nil)
        optsView.register(nibName, forCellWithReuseIdentifier: "OptCell")
        optsView.isOpaque = false
        let bg_img = UIImageView(image: #imageLiteral(resourceName: "question_bg_img"))
        bg_img.contentMode = .scaleAspectFill
        optsView.backgroundView = bg_img
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        addOptionField.endEditing(true)
    }
    
    // Override functions
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
