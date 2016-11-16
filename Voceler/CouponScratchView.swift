//
//  CouponScratchView.swift
//  QAQ
//
//  Created by 钟镇阳 on 10/22/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import ScratchCard
import SCLAlertView
import FXBlurView

class CouponScratchView: ScratchUIView {
    var parentVC:UIViewController!
    var alertShowed = false
    init(img:UIImage, parent:UIViewController){
        var mask = #imageLiteral(resourceName: "coupon_sample").blurredImage(withRadius: 100, iterations: 2, tintColor: .clear)!
        mask = mask.resize(newWidth: 100)
        super.init(frame: CGRect(x: parent.view.left, y: parent.view.top, width: parent.view.width, height:parent.view.height), Coupon: #imageLiteral(resourceName: "coupon_sample"), MaskImage: mask, ScratchWidth: 40)
        parentVC = parent
        alertShowed = false
        parent.view.addSubview(self)
        becomeFirstResponder()
        _ = sd_layout().topSpaceToView(parent.view, 0)?.rightSpaceToView(parent.view, 0)?.leftSpaceToView(parent.view, 0)?.bottomSpaceToView(parent.view, 0)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.ScratchComplete, object: nil, queue: nil, using: { (noti) in
            controllerManager?.mainVC.swipeEnable = true
            if !self.alertShowed{
                self.alertShowed = true
                self.scratchCompleteAlert()
            }
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func scratchCompleteAlert(){
        _ = SCLAlertView().showSuccess("Scratch Complete", subTitle: "Sorry, you didn't get any rewards, please try again next time.")
    }
}
