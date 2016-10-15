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

class QuestionView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {

    
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
    var currQuestion:QuestionModel?
    var collectionView:UICollectionView!
    var pullUpMask = UILabel()
//    var optArr = [OptionModel]()
    var collectionFooter:MJRefreshBackNormalFooter!
    var parent:UIViewController!
    var focusLayout:SFFocusViewLayout!
    
    // Actions
    @IBAction func askerInfo(_ sender: AnyObject) {
        showUser(user: asker)
    }
    
    @IBAction func likeAction(_ sender: AnyObject) {
        if parent is QuestionVC{
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
        collectionView.isUserInteractionEnabled = true
        
        let oRef = question.qRef.child("options")
        oRef.observe(.childAdded, with: { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any>{
                let opt = OptionModel(ref: snapshot.ref, dict: dict)
                question.optArrAdd(option: opt)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                self.pullUpMask.isHidden = true
            }
        })
        
        collectionView.mj_footer = collectionFooter
        asker = question.qAnonymous ? nil : UserModel.getUser(uid: question.qAskerID, getProfile: true)
        if let asker = asker{
            NotificationCenter.default.addObserver(forName: NSNotification.Name(asker.uid+"username"), object: nil, queue: nil, using: { (noti) in
                self.askerLbl.text = asker.username
            })
        }
        askerLbl.text = asker?.username
        pullUpMask.isHidden = question.qOptions.count > 0
        titlebarHeight.constant = 56
        collectionView.board(radius: 0, width: 1, color: .gray)
        
        collectionView.reloadData()
        if question.qOptions.count > 0{
            collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: UICollectionViewScrollPosition.top, animated: false)
        }
        
    }
    
    func showUser(user:UserModel?){
        if let user = user{
            let vc = VC(name: "Profile", isNav: false, isCenter: false, isNew: true) as! ProfileVC
            vc.thisUser = user
            user.profileVC = vc
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
        initTable()
        
        pullUpMask.text = "Pull up to add an option"
        pullUpMask.textAlignment = .center
        pullUpMask.isHidden = true
        pullUpMask.textColor = .gray
        collectionView.addSubview(pullUpMask)
        _ = pullUpMask.sd_layout().topSpaceToView(detailTV, 10)?.leftSpaceToView(collectionView, 0)?.rightSpaceToView(collectionView, 0)?.heightIs(30)
    }
    
    func addOption(text:String){
        let opt = OptionModel(description: text, offerBy: (appSetting.isAnonymous) ? nil : currUser!.uid)
        currQuestion?.addOption(opt: opt)
//        collectionView.reloadData()
        //        pullDownMask.isHidden = true
        pullUpMask.isHidden = true
//        collectionView.scrollToItem(at: IndexPath(row: optArr.count-1, section: 0), at: UICollectionViewScrollPosition.top, animated: false)
        currQuestion?.choose(val: opt.oRef.key)
    }
    
    private func initTable() {
        // Do any additional setup after loading the view.
        focusLayout = SFFocusViewLayout()
        focusLayout.standardHeight = 50
        focusLayout.focusedHeight = 180
        focusLayout.dragOffset = 100
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 100, height: 110), collectionViewLayout: focusLayout)
        addSubview(collectionView)
        _ = collectionView.sd_layout()
            .topSpaceToView(detailTV, 0)?
            .bottomSpaceToView(self, 0)?
            .leftSpaceToView(self, 0)?
            .rightSpaceToView(self, 0)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(CollectionViewCell.self)
        
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        collectionView.backgroundColor = .white
        
        addHeaderFooter()
    }
    
    private func addHeaderFooter(){
        if let vc = parent as? QuestionVC{
            let header = MJRefreshNormalHeader(refreshingBlock: {
                self.currQuestion?.choose()
                vc.nextContent()
                self.collectionView.mj_header.endRefreshing()
            })!
            header.lastUpdatedTimeLabel.isHidden = true
            header.setTitle("Next question", for: .pulling)
            header.setTitle("Pull down to get next question", for: .idle)
            collectionView.mj_header = header
            
            collectionFooter = MJRefreshBackNormalFooter(refreshingBlock: {
                let alert = SCLAlertView()
                let optionText = alert.addTextView()
                _ = alert.addButton("Add", action: {
                    if optionText.text == ""{
                        _ = SCLAlertView().showError("Sorry", subTitle: "Option text cannot be empty.")
                    }
                    else{
                        self.addOption(text: optionText.text)
                        vc.nextContent()
                    }
                })
                _ = alert.showEdit("Another Option", subTitle: "", closeButtonTitle: "Cancel")
                self.collectionView.mj_footer.endRefreshing()
            })!
            collectionFooter.setTitle("Pull to add an option", for: .idle)
            collectionFooter.setTitle("Add an option", for: .pulling)
        }
    }
    
    func setDescription() {
        detailTV.isSelectable = true
        handler.setText(currQuestion?.qDescrption, withAnimation: true)
        detailTV.isSelectable = false
    }
    
    func setup(parent:UIViewController, question:QuestionModel) {
        self.parent = parent
        setupUI()
        setQuestion(question: question)
    }
    
    // Override functions
    override func awakeFromNib() {
        super.awakeFromNib()
        if let _ = parent as? InProgressVC{
            likeBtn?.isHidden = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currQuestion!.qOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as CollectionViewCell
        cell.setup(parent: self, option: currQuestion!.qOptions[indexPath.row], indexPath: indexPath)
        return cell
    }
    
    @objc(collectionView:willDisplayCell:forItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        (cell as! CollectionViewCell).option = currQuestion?.qOptions[indexPath.row]
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let focusViewLayout = collectionView.collectionViewLayout as? SFFocusViewLayout else {
            fatalError("error casting focus layout from collection view")
        }
        
        let offset = focusViewLayout.dragOffset * CGFloat(indexPath.item)
        if collectionView.contentOffset.y != offset {
            collectionView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
        }
        
    }

}
