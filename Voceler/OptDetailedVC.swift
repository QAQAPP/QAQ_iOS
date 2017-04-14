//
//  OptDetailedVC.swift
//  QAQ
//
//  Created by Zhongyang Gao on 2/8/17.
//  Copyright © 2017 Zhenyang Zhong. All rights reserved.
//

import UIKit

class OptDetailedVC: UIViewController,UINavigationControllerDelegate {
	
	
	@IBOutlet  var userAvatarImageView: UIImageView!
	
	@IBOutlet  var userNameLabel: UILabel!
	
	@IBOutlet  var optionDescriptionLabel: UILabel!
	
	@IBOutlet  var optionTextView: UITextView!
	
	var option: OptionModel! = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		userNameLabel.text = "user"
		
		// Do any additional setup after loading the view.
		setOptionModel(option: option)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func setOptionModel (option: OptionModel) {
		self.option = option
//		let user = UserModel.getUser(uid: option.oOfferBy!, getProfile: true)
//		if (user.profileImg != nil) {
//			userAvatarImageView.image = user.profileImg
//		}
		//		vc.userAvatarImageView.image = user.profileImg!
//		if (user.username != nil ) {
//			userNameLabel.text = user.username
//		}
		
		optionDescriptionLabel.text = "Empty description for now"
		optionTextView.text = option.oDescription
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
