//
//  ButtonBar.swift
//  QAQ
//
//  Created by Zhongyang Gao on 3/4/17.
//  Copyright © 2017 Zhenyang Zhong. All rights reserved.
//

import UIKit

class ButtonBar: UIView {

	@IBOutlet weak var leftButton: UIButton!
	@IBOutlet weak var rightButton: UIButton!
	
	var view:UIView!;
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		loadViewFromNib ()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		loadViewFromNib ()
	}
	func loadViewFromNib() {
		let bundle = Bundle(for: type(of: self))
		let nib = UINib(nibName: "ButtonBar", bundle: bundle)
		let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
		view.frame = bounds
		view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		self.addSubview(view);
	}
	
	

	/*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
