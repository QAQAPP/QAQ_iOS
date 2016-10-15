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
            let questionView = Bundle.main.loadNibNamed("QuestionView", owner: self, options: nil)!.first as! QuestionView
            questionView.setup(parent: self, question: content)
        }
        else{
            let noContentView = Bundle.main.loadNibNamed("NoContentView", owner: self, options: nil)!.first as! NoContentView
            noContentView.setupView(parent: self)
        }
    }
}
