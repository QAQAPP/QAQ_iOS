//
//  UserTableCell.swift
//  QAQ
//
//  Created by Zhenyang Zhong on 2/2/17.
//  Copyright © 2017 Zhenyang Zhong. All rights reserved.
//

import UIKit
import BadgeSwift

class UserTableCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var badgeValue: BadgeSwift!
    var notiVal = 0{
        didSet{
            if notiVal > 0{
                badgeValue.isHidden = false
                badgeValue.text = String(notiVal)
            }
            else{
                badgeValue.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        badgeValue.board(radius: 10, width: 0, color: .clear)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
