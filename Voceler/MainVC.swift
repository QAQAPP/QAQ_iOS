//
//  QuestionVC.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 6/26/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import GrowingTextViewHandler
import MJRefresh
import SCLAlertView
import SFFocusViewLayout
import SCLAlertView
import UIViewController_NavigationBar
import ScratchCard
import SDAutoLayout
import MMDrawerController
import BlurImageProcessor
import FXBlurView
import UIImage_Resize
import BFPaperButton
import LTMorphingLabel

class MainVC: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate{
    let vc_max_count = 7
    private var contentVCs = [UIViewController]()
    let page = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    var currVC : UIViewController!
    
    var point = 0{
        didSet{
            scoreLabel.text = "\(point)"
        }
    }
    
    var swipeEnable = true{
        didSet{
            if swipeEnable{
                page.dataSource = self
            }
            else{
                page.dataSource = nil
            }
        }
    }
    
    override func showInfo() {
        var showUser = currUser
        if let vc = currVC as? ContentVC{
            if let view = vc.contentView as? QuestionView{
                if view.currQuestion.qAnonymous{
                    showUser = nil
                }
                else if let user = view.asker{
                    showUser = user
                }
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
        if let vc = currVC as? ContentVC{
            if let questionView = vc.contentView as? QuestionView{
                questionView.likeQuestion()
            }
        }
    }
    
    var likeBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "star-32").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(likeAction))
    var profileItem = UIBarButtonItem(image: #imageLiteral(resourceName: "user_male_circle-32"), style: .plain, target: self, action: #selector(showInfo))
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?{
//        if let index = contentVCs.index(of: viewController), index > 0 && swipeEnable{
//            return contentVCs[index-1]
//        }
//        else{
//            return nil
//        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?{
        if let index = contentVCs.index(of: viewController), index < contentVCs.count - 1 && swipeEnable{
            let vc = contentVCs[index+1]
            if index > 1{
                _ = contentVCs.removeFirst()
            }
            return vc
        }
        else {
            if let question = questionManager?.getQuestion(){
                self.addQuestion(question: question)
            }
            if let vc = currVC as? ContentVC, vc.contentView is UIButton{
                return nil
            }
            else{
                addLoadMoreVC()
                return contentVCs.last!
            }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        point += 1
        print(currVC, contentVCs, pendingViewControllers)
        if let vc = currVC as? ContentVC, currVC == contentVCs[1] && pendingViewControllers.first != contentVCs.first{
            vc.upvote()
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed{
            currVC = page.viewControllers?.first
            while let index = contentVCs.index(of: currVC), index > 1{
                contentVCs.removeFirst()
            }
        }
    }
    
    // Functions
    func addNoContentVC(){
        let vc = ContentVC()
        let label = UILabel()
        vc.contentView = label
        label.text = "scroll left to begin"
        vc.view.backgroundColor = .white
        label.textAlignment = .center
        vc.view.addSubview(label)
        _ = label.sd_layout().topSpaceToView(vc.view, 0)?.bottomSpaceToView(vc.view, 0)?.leftSpaceToView(vc.view, 0)?.rightSpaceToView(vc.view, 0)
        contentVCs.append(vc)
    }
    
    func addCouponVC(img:UIImage){
        let vc = CouponVC(img: img)
        contentVCs.append(vc)
    }
    
    func addLoadMoreVC(){
        let vc = ContentVC()
        let btn = BFPaperButton(raised: false)!
        btn.setTitle("Load More", for: [])
        btn.backgroundColor = themeColor
        btn.setTitleColor(.white, for: [])
        btn.addTarget(self, action: #selector(loadQuestions), for: .touchUpInside)
        vc.view.addSubview(btn)
        vc.contentView = btn
        _ = btn.sd_layout().topSpaceToView(vc.view, 0)?.bottomSpaceToView(vc.view, 0)?.leftSpaceToView(vc.view, 0)?.rightSpaceToView(vc.view, 0)
        contentVCs.append(vc)
    }
    
    func addQuestion(question:QuestionModel){
        let questionView = Bundle.main.loadNibNamed("QuestionView", owner: self, options: nil)!.first as! QuestionView
        if let vc = contentVCs.last as? ContentVC, vc.contentView is UIButton{
            UIView.transition(with: vc.view, duration: 1, options: .transitionCrossDissolve, animations: {
                vc.contentView.removeFromSuperview()
                vc.contentView = questionView
                questionView.setup(parent: vc, question: question)
                _ = questionView.sd_layout().topSpaceToView(vc.view, 0)?.bottomSpaceToView(vc.view, 0)?.leftSpaceToView(vc.view, 0)?.rightSpaceToView(vc.view, 0)
                }, completion: nil)
        }
        else{
            let vc = ContentVC()
            vc.contentView = questionView
            questionView.setup(parent: vc, question: question)
            _ = questionView.sd_layout().topSpaceToView(vc.view, 0)?.bottomSpaceToView(vc.view, 0)?.leftSpaceToView(vc.view, 0)?.rightSpaceToView(vc.view, 0)
            contentVCs.append(vc)
        }
    }
    
    func loadQuestions(){
        while self.contentVCs.count < self.vc_max_count{
            if let question = questionManager?.getQuestion(){
                self.addQuestion(question: question)
            }
            else{
                break
            }
        }
    }
    
    let scoreLabel = LTMorphingLabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        scoreLabel.morphingEffect = .evaporate
        point = 0
        navigationItem.titleView = scoreLabel
        _ = scoreLabel.sd_layout().widthIs(200)?.heightIs(42)
        scoreLabel.textAlignment = .center
        scoreLabel.textColor = .white
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadQuestions), name: Notification.Name.QuestionLoaded, object: nil)
        view.backgroundColor = .white
        page.dataSource = self
        page.delegate = self
        addNoContentVC()
        addCouponVC(img: #imageLiteral(resourceName: "coupon_sample"))
        addChildViewController(page)
        view.addSubview(page.view)
        currVC = contentVCs.first
        page.setViewControllers([contentVCs.first!], direction: .forward, animated: true, completion: nil)
        page.didMove(toParentViewController: self)
    
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
    
    var swipeComplete = true
    func nextContent(){
        swipeComplete = false
        if #available(iOS 10.0, *) {
            Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { (timer) in
                self.swipeToNext()
            }
        } else {
            _ = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(swipeToNext), userInfo: nil, repeats: false)
        }
    }
    
    func swipeToNext(){
        swipeComplete = true
        if let vc = pageViewController(page, viewControllerAfter: currVC){
            page.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
            currVC = vc
        }
    }
}
