////
////  QuestionVC.swift
////  QAQ
////
////  Created by 钟镇阳 on 10/22/16.
////  Copyright © 2016 Zhenyang Zhong. All rights reserved.
////
//
//import UIKit
//import SDAutoLayout
//
//class CouponVC: UIViewController {
//    
//    var couponScratchView : CouponScratchView!
//    
//    init(img:UIImage) {
//        super.init(nibName: nil, bundle: nil)
//        couponScratchView = CouponScratchView(img: img, parent: self)
//        NotificationCenter.default.addObserver(forName: Notification.Name.ScratchComplete, object: nil, queue: nil, using: { (noti) in
//            let imgView = UIImageView(image: img)
//            UIView.transition(with: self.view, duration: 1, options: .transitionCrossDissolve, animations: {
//                self.view.addSubview(imgView)
//                self.couponScratchView.removeFromSuperview()
//                _ = imgView.sd_layout().topSpaceToView(self.view, 0)?.bottomSpaceToView(self.view, 0)?.leftSpaceToView(self.view, 0)?.rightSpaceToView(self.view, 0)
//                }, completion: nil)
//        })
//        _ = view.sd_layout().bottomSpaceToView(view, 0)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        let vc = controllerManager?.mainVC
//        let item = vc?.navigationItem
//        item?.leftBarButtonItem?.image = #imageLiteral(resourceName: "user_male_circle-32")
//        item?.setRightBarButton(nil, animated: true)
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        if couponScratchView.getScratchPercent() < 0.5{
//            controllerManager?.mainVC.disableSwipe()
//        }
//        controllerManager?.mainVC.currVC = self
//    }
//}
