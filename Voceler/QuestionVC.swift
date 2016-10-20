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

class QuestionVC: UIViewController{
    // Actions
    @IBAction func showAskVC(_ sender: AnyObject) {
        if currUser!.qInProgress.count >= currUser!.qInProgressLimit{
            _ = SCLAlertView().showError("Sorry", subTitle: "You are only allowed to have up to \(currUser!.qInProgressLimit) in progress questions. Please conclude a question.")
        }
        else{
            let vc = VC(name: "Ask Question", isCenter: false) as! UINavigationController
            show(vc, sender: self)
        }
    }
    
    // Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setContent()
        NotificationCenter.default.addObserver(forName: NSNotification.Name("QuestionLoaded"), object: nil, queue: nil, using: { (noti) in
            if self.view.subviews.first is NoContentView{
                self.setContent()
            }
        })
        navigationBar.setColor(color: themeColor)
    }
    
    func nextContent(){
        if #available(iOS 10.0, *) {
            Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { (timer) in
                self.setContent()
            }
        } else {
            _ = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(setContent), userInfo: nil, repeats: false)
        }
    }
    
    func setContent(){
        for view in self.view.subviews {
            view.removeFromSuperview()
        }
        if let content = questionManager.getQuestion(){
            isScratch = false
            drawer.openDrawerGestureModeMask = .panningCenterView
            let questionView = Bundle.main.loadNibNamed("QuestionView", owner: self, options: nil)!.first as! QuestionView
            questionView.setup(parent: self, question: content)
        }
        else{
//            let noContentView = Bundle.main.loadNibNamed("NoContentView", owner: self, options: nil)!.first as! NoContentView
//            noContentView.setupView(parent: self)
            var img = #imageLiteral(resourceName: "coupon_sample").blurredImage(withRadius: 100, iterations: 1, tintColor: .clear)!
            img = img.resize(newWidth: 100)
            setupScratch(mask: img)
        }
    }
    
    var isScratch = false
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        drawer.openDrawerGestureModeMask = .panningCenterView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        drawer.openDrawerGestureModeMask = isScratch ? [] : .panningCenterView
    }
    
    func scratchCompleteAlert(){
        let alert = SCLAlertView()
        _ = alert.addButton("Next", action: {
            self.setContent()
        })
        _ = alert.showSuccess("Scratch Complete", subTitle: "Sorry, you didn't get any rewards, please try again next time.")
    }
    
    var alertShowed = false
    
    func setupScratch(mask:UIImage){
        let scratch = ScratchUIView(frame: CGRect(x: view.left, y: view.top, width:view.width, height:view.height), Coupon: #imageLiteral(resourceName: "coupon_sample"), MaskImage: mask, ScratchWidth: 40)
        isScratch = true
        alertShowed = false
        view.addSubview(scratch)
        scratch.becomeFirstResponder()
        _ = scratch.sd_layout().topSpaceToView(view, 0)?.rightSpaceToView(view, 0)?.leftSpaceToView(view, 0)?.bottomSpaceToView(view, 0)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.ScratchComplete, object: nil, queue: nil, using: { (noti) in
            if !self.alertShowed{
                self.alertShowed = true
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.scratchCompleteAlert))
                scratch.addGestureRecognizer(tap)
                self.scratchCompleteAlert()
            }
        })
    }
}
