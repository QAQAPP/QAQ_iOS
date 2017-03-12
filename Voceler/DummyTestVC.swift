//
//  DummyTestVC.swift
//  QAQ
//
//  Created by Zhongyang Gao on 3/4/17.
//  Copyright © 2017 Zhenyang Zhong. All rights reserved.
//

import UIKit

class DummyTestVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewWillAppear(_ animated: Bool) {
		if ((self.navigationController) != nil)
		{
			self.navigationController?.preferredContentSize = self.preferredContentSize;
			self.navigationController?.setNavigationBarHidden(true, animated: animated)
		}
//		self.preferredContentSize = CGSize(width: 200, height: 200)
//		self.view.backgroundColor = UIColor.red
//		print("DummyVC: setting content size")
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

