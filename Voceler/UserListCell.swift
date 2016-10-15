//
//  UserListCell.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 6/29/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit

class UserListCell: UITableViewCell {

    @IBOutlet weak var userImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userImg.board(radius: 24, width: 0, color: UIColor.clear)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
