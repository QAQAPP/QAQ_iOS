//
//  SwipeAlertVC.swift
//  QAQ
//
//  Created by 钟镇阳 on 11/4/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import SCLAlertView

class SwipeAlertVC: SCLAlertView {

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        controllerManager?.mainVC.nextContent()
    }
    
}
