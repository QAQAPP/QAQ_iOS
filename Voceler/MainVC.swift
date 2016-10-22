//
//  QuestionVC.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 6/26/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import GrowingTextViewHandler
import FoldingCell
import MJRefresh
import SCLAlertView
import SFFocusViewLayout
import LTNavigationBar
import SCLAlertView
import UIViewController_NavigationBar
import ScratchCard
import SDAutoLayout
import MMDrawerController
import BlurImageProcessor
import FXBlurView
import UIImage_Resize

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
    var contentVCs = [UIViewController]()
    let page = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    var currVC : UIViewController!

//    var couponVC : UIViewController?
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
        if let index = contentVCs.index(of: viewController), index > 0 && swipeEnable{
            currVC = contentVCs[index-1]
            return contentVCs[index-1]
        }
        else{
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?{
        if let question = questionManager.getQuestion(){
            self.addQuestion(question: question)
        }
        if let index = contentVCs.index(of: viewController), index < contentVCs.count - 1 && swipeEnable{
            currVC = contentVCs[index+1]
            if index >= 2{
                _ = contentVCs.removeFirst()
            }
            return currVC
        }
        else{
            return nil
        }
    }
    
//    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
//        if let prev = previousViewControllers.last, let index = contentVCs.index(of: prev){
//            if index + 1 < contentVCs.count && completed && finished{
//                let vc = contentVCs[index + 1]
//                for view in vc.view.subviews{
//                    if let view = view as? CouponScratchView{
//                        if view.getScratchPercent() < 0.5{
//                            swipeEnable = false
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    // Functions
    func addNoContentVC(){
        let vc = UIViewController()
        let label = UILabel()
        label.text = "scroll left to begin"
        vc.view.backgroundColor = .white
        label.textAlignment = .center
        vc.view.addSubview(label)
        _ = label.sd_layout().topSpaceToView(vc.view, 0)?.bottomSpaceToView(vc.view, 0)?.leftSpaceToView(vc.view, 0)?.rightSpaceToView(vc.view, 0)
        contentVCs.append(vc)
    }
    
    func addCouponVC(img:UIImage){
        let vc = CouponVC(img: img)
//        _ = CouponScratchView(img: img, parent: vc)
        contentVCs.append(vc)
    }
    
    func addQuestion(question:QuestionModel){
        let vc = UIViewController()
        let questionView = Bundle.main.loadNibNamed("QuestionView", owner: self, options: nil)!.first as! QuestionView
        questionView.setup(parent: vc, question: question)
        _ = questionView.sd_layout().bottomSpaceToView(vc.view, 0)
        contentVCs.append(vc)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setContent()
        NotificationCenter.default.addObserver(forName: NSNotification.Name("QuestionLoaded"), object: nil, queue: nil, using: { (noti) in
            while self.contentVCs.count < self.vc_max_count{
                if let question = questionManager.getQuestion(){
                    self.addQuestion(question: question)
                }
                else{
                    break
                }
            }
//            if let question = noti.userInfo?["question"] as? QuestionModel{
//                self.addQuestion(question: question)
//            }
//            if self.view.subviews.first is NoContentView{
//                self.setContent()
//            }
        })
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
        if let question = questionManager.getQuestion(){
            addQuestion(question: question)
        }
    }
    
    func nextContent(){
        if #available(iOS 10.0, *) {
            Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { (timer) in
                self.swipeToNext()
            }
        } else {
            _ = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(swipeToNext), userInfo: nil, repeats: false)
        }
    }

    func swipeToNext(){
        if let vc = pageViewController(page, viewControllerAfter: currVC){
            page.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
        }
    }
}
