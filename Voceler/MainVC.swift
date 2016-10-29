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

class MainVC: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate{
    // Actions
    //    @IBAction func showAskVC(_ sender: AnyObject) {
    //        if currUser!.qInProgress.count >= currUser!.qInProgressLimit{
    //            _ = SCLAlertView().showError("Sorry", subTitle: "You are only allowed to have up to \(currUser!.qInProgressLimit) in progress questions. Please conclude a question.")
    //        }
    //        else{
    //            // TODO
    ////            let vc = VC(name: "Ask Question", isCenter: false) as! UINavigationController
    ////            show(vc, sender: self)
    //        }
    //    }
    let vc_max_count = 7
    private var contentVCs = [UIViewController]()
    let page = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    var currVC : UIViewController!
    
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
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed{
            currVC = page.viewControllers?.first
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        setContent()
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
