//
//  TextViewVC.swift
//  QAQ
//
//  Created by 钟镇阳 on 10/9/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit

class TextViewVC: UIViewController {

    var parentVC:SettingsVC?
    func setup(vc:SettingsVC){
        parentVC = vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if let vc = parentVC{
//            let btn = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(vc.uploadText))
//            navigationItem.set = btn
//             navigationController!.navigationItem.setRightBarButton(UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(vc.uploadText)), animated: true)
//        }
    }

}
