//
//  QuestionVC.swift
//  QAQ
//
//  Created by 钟镇阳 on 10/22/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import SDAutoLayout

class CouponVC: UIViewController {
    
    var couponScratchView : CouponScratchView!
    
    init(img:UIImage) {
        super.init(nibName: nil, bundle: nil)
        couponScratchView = CouponScratchView(img: img, parent: self)
        NotificationCenter.default.addObserver(forName: Notification.Name.ScratchComplete, object: nil, queue: nil, using: { (noti) in
            let imgView = UIImageView(image: img)
            UIView.transition(with: self.view, duration: 1, options: .transitionCrossDissolve, animations: {
                self.view.addSubview(imgView)
                self.couponScratchView.removeFromSuperview()
                _ = imgView.sd_layout().topSpaceToView(self.view, 0)?.bottomSpaceToView(self.view, 0)?.leftSpaceToView(self.view, 0)?.rightSpaceToView(self.view, 0)
                }, completion: nil)
        })
        _ = view.sd_layout().bottomSpaceToView(view, 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func disableSwipe(){
        controllerManager?.mainVC.swipeEnable = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if couponScratchView.getScratchPercent() < 0.5{
            if #available(iOS 10.0, *) {
                Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { (timer) in
                    self.disableSwipe()
                }
            } else {
                // Fallback on earlier versions
                _ = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(disableSwipe), userInfo: nil, repeats: false)
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        controllerManager?.mainVC.swipeEnable = true
    }
}
