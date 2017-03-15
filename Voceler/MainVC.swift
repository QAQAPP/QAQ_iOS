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

class MainVC: UIViewController{
    
    private var contentViews = [UIView]()
    var currView:UIView?
    var swipeEnable = true
    
    override func showInfo() {
        var showUser = currUser
        if let view = currView as? QuestionView{
            if view.currQuestion.qAnonymous{
                showUser = nil
            }
            else if let user = view.asker{
                showUser = user
            }
        }
        if let user = showUser, let vc = controllerManager?.profileVC(user: user){
            navigationController?.pushViewController(vc, animated: true)
        }
        else{
            _ = SCLAlertView().showWarning("Ooops", subTitle: "Anonymous user.")
        }
    }
    
    func likeAction(){
        if let questionView = currView as? QuestionView{
            questionView.likeQuestion()
        }
    }
    
    var likeBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "star-32").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(likeAction))
    var profileItem = UIBarButtonItem(image: #imageLiteral(resourceName: "user_male_circle-32"), style: .plain, target: self, action: #selector(showInfo))

    // Functions
    func addCouponVC(img:UIImage){
        let view = CouponScratchView(img: img, parent: self)
        contentViews.append(view)
    }
    
    func addLoadMoreVC(){
        let btn = BFPaperButton(raised: false)!
        btn.setTitle("Load More", for: [])
        btn.backgroundColor = themeColor
        btn.setTitleColor(.white, for: [])
        btn.addTarget(self, action: #selector(loadQuestions), for: .touchUpInside)
        contentViews.append(btn)
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
            self.loadQuestions()
        }
    }
    
    func addQuestion(question:QuestionModel){
        let questionView = Bundle.main.loadNibNamed("QuestionView", owner: self, options: nil)!.first as! QuestionView
        if contentViews.isEmpty && currView is UIButton{
//            UIView.transition(with: currView!, duration: 1, options: .curveEaseIn, animations: {
                self.currView?.removeFromSuperview()
                self.currView = questionView
                self.view.addSubview(questionView)
                questionView.currQuestion = question
                _ = questionView.sd_layout().topSpaceToView(self.scoreLabel, 4)?.bottomSpaceToView(self.view, 0)?.leftSpaceToView(self.view, 0)?.rightSpaceToView(self.view, 0)
                questionView.setup(parent: self)
//            }, completion: nil)
        }
        else{
            questionView.currQuestion = question
            contentViews.append(questionView)
        }
    }
    
    func loadQuestions(){
        if let question = questionManager?.getQuestion(){
            self.addQuestion(question: question)
        }
        else if !contentViews.isEmpty && currView is UIButton{
            nextContent()
        }
    }
    
    let scoreLabel = LTMorphingLabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        scoreLabel.morphingEffect = .evaporate
        scoreLabel.text = "-.--"
        scoreLabel.font = UIFont(name: "Arial", size: 30)

        view.addSubview(scoreLabel)
        _ = scoreLabel.sd_layout().topSpaceToView(view, 20)?.centerXEqualToView(view)?.widthIs(200)?.heightIs(42)
        scoreLabel.textAlignment = .center
        scoreLabel.textColor = themeColor
        
        view.backgroundColor = .white
    
        likeBtn.target = self
        profileItem.target = self
        navigationItem.rightBarButtonItem = nil
        navigationItem.leftBarButtonItem = profileItem
    }
    
    func addContent(){
        if let question = questionManager?.getQuestion(){
            addQuestion(question: question)
        }
    }
    
    func nextContent(){
        addContent()
        currView?.removeFromSuperview()
        if contentViews.isEmpty{
            addLoadMoreVC()
        }
        currView = contentViews.removeFirst()
        view.addSubview(currView!)
        _ = currView!.sd_layout().topSpaceToView(scoreLabel, 4)?.bottomSpaceToView(view, 0)?.leftSpaceToView(view, 0)?.rightSpaceToView(view, 0)
        if let questionView = currView as? QuestionView{
            questionView.setup(parent: self)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nextContent()
    }
}
