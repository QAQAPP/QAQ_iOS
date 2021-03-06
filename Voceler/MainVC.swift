//
//  QuestionVC.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 6/26/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import GrowingTextViewHandler_Swift
import MJRefresh
import SCLAlertView
import SFFocusViewLayout
import SCLAlertView
import UIViewController_NavigationBar
import ScratchCard
import SDAutoLayout
import MMDrawerController
//import FXBlurView
import UIImage_Resize
import BFPaperButton
import LTMorphingLabel
import IQKeyboardManagerSwift
import FirebaseDatabase

class MainVC: UIViewController{
    var currView:UIView?
    var swipeEnable = true
    
//    func showInfo() {
//        if let view = currView as? QuestionView{
            // TODO: SHOW USER INFO
//            if let user = showUser, let vc = controllerManager?.getUserVC(user: user){
//                navigationController?.pushViewController(vc, animated: true)
//            }
//            else{
//                _ = SCLAlertView().showWarning("Ooops", subTitle: "Anonymous user.")
//            }
//        }
//    }
    
    func likeAction(){
        if let questionView = currView as? QuestionView{
            questionView.likeQuestion()
        }
    }
    
    var likeBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "star-32").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(likeAction))
//    var profileItem = UIBarButtonItem(image: #imageLiteral(resourceName: "user_male_circle-32"), style: .plain, target: self, action: #selector(showInfo))

    // Functions
    func addMoreView()->UIView{
        let btn = BFPaperButton(raised: false)!
        btn.setImage(#imageLiteral(resourceName: "no_question"), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(nextContent), for: .touchUpInside)
        return btn
    }
    
//    func addQuestion(qRef:FIRDatabaseReference){
//        let questionView = Bundle.main.loadNibNamed("QuestionView", owner: self, options: nil)!.first as! QuestionView
//                self.currView?.removeFromSuperview()
//                self.currView = questionView
//                self.view.addSubview(questionView)
//                _ = questionView.sd_layout().topSpaceToView(self.scoreLabel, 4)?.bottomSpaceToView(self.view, 0)?.leftSpaceToView(self.view, 0)?.rightSpaceToView(self.view, 0)
//                questionView.setup(parent: self, qRef:qRef)
//        }
//        else{
//            questionView.currQuestion = QuestionModel(ref: qRef, questionView: questionView)
//            contentViews.append(questionView)
//        }
//    }
    
    let scoreLabel = LTMorphingLabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        scoreLabel.morphingEffect = .evaporate
        scoreLabel.text = "$-.--"
        scoreLabel.font = UIFont(name: "Arial", size: 30)

        view.addSubview(scoreLabel)
        _ = scoreLabel.sd_layout().topSpaceToView(view, 20)?.centerXEqualToView(view)?.widthIs(200)?.heightIs(42)
        scoreLabel.textAlignment = .center
        scoreLabel.textColor = themeColor
        
        view.backgroundColor = .white
    
        likeBtn.target = self
//        profileItem.target = self
        navigationItem.rightBarButtonItem = nil
//        navigationItem.leftBarButtonItem = profileItem
        
        
//        for i in 0..<100{
//            let question = QuestionModel()
//            question.qAskerID = currUser!.uid
//            question.qDescrption = "Sample Question \(i + 1) by Zhenyang Zhong"
//            question.qOptions = [OptionModel]()
//            question.postQuestion()
//        }
    }
    
    func addContent()->QuestionView?{
        if let ref = questionManager?.getQuestion(){
            let questionView = Bundle.main.loadNibNamed("QuestionView", owner: self, options: nil)!.first as! QuestionView
            questionView.setup(parent: self, qRef:ref)
            return questionView
        }
        else{
            return nil
        }
    }
    
    func nextContent(){
        currView?.removeFromSuperview()
        if let questionView = addContent(){
            currView = questionView
        }
        else{
            currView = addMoreView()
        }
        view.addSubview(currView!)
        _ = currView!.sd_layout().topSpaceToView(scoreLabel, 4)?.bottomSpaceToView(view, 0)?.leftSpaceToView(view, 0)?.rightSpaceToView(view, 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if currView == nil || currView is UIButton{
            nextContent()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
		IQKeyboardManager.sharedManager().disabledToolbarClasses = [MainVC.self]
    }
}
