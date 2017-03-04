//
//  UserTableCell.swift
//  QAQ
//
//  Created by Zhenyang Zhong on 2/2/17.
//  Copyright © 2017 Zhenyang Zhong. All rights reserved.
//

import UIKit

class UserTableCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
