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

class QuestionView: UIView, UICollectionViewDataSource, UICollectionViewDelegate{
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
    var optsView:UICollectionView!
    var pullUpMask = UILabel()
    var parent:UIViewController!
    
    // Actions
    @IBAction func askerInfo(_ sender: AnyObject) {
        showUser(user: asker)
    }
    
    @IBAction func postAction(_ sender: Any) {
        endEditing(true)
        if let text = addOptionField.text, !text.isEmpty{
            addOption(text: text)
        }
        addOptionField.text = ""
        controllerManager?.mainVC.nextContent()
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
                self.askerLbl.text = asker.username
            })
        }
        askerLbl.text = asker?.username
        pullUpMask.isHidden = question.qOptions.count > 0
        titlebarHeight.constant = 56
        
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
        currQuestion.userChoosed = true
        let option = OptionModel(question: currQuestion, description: text, offerBy: (appSetting.isAnonymous) ? nil : currUser!.uid)
        currQuestion?.addOption(opt: option)
        pullUpMask.isHidden = true
        currQuestion?.choose(val: option.oRef.key)
        let indexPath = IndexPath(row: currQuestion.qOptions.count, section: 0)
        optsView.delegate?.collectionView!(optsView, didSelectItemAt: indexPath)
    }
    
    func setDescription() {
        detailTV.isSelectable = true
        handler.setText(currQuestion?.qDescrption, withAnimation: true)
        detailTV.isSelectable = false
    }
    
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
        optsView.board(radius: 0, width: 1, color: .black)
        optsView.delegate = self
        optsView.dataSource = self
        let nibName = UINib(nibName: "OptCell", bundle:nil)
        optsView.register(nibName, forCellWithReuseIdentifier: "OptCell")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        addOptionField.endEditing(true)
    }
    
    // Override functions
    override func awakeFromNib() {
        super.awakeFromNib()
        if let _ = parent as? InProgressVC{
            likeBtn?.isHidden = true
        }
    }

}
