//
//  OptDetailedVC.swift
//  QAQ
//
//  Created by Zhongyang Gao on 2/8/17.
//  Copyright © 2017 Zhenyang Zhong. All rights reserved.
//

import UIKit

class OptDetailedVC: UIViewController {


	@IBOutlet weak var userAvatarImageView: UIImageView!
	
	@IBOutlet weak var userNameLabel: UILabel!
	
	@IBOutlet weak var optionDescriptionLabel: UILabel!
	
	@IBOutlet weak var optionTextView: UITextView!

	var optionText:String!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		optionTextView.text = optionText

        // Do any additional setup after loading the view.
		
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
