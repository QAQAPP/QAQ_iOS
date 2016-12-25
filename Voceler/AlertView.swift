//
//  AlertView.swift
//  QAQ
//
//  Created by Zhenyang Zhong on 12/15/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import SCLAlertView

class AlertView: SCLAlertView {
    
    var action:(()->())?
    
    override func viewDidDisappear(_ animated: Bool) {
        if let action = action{
            action()
        }
    }
}
