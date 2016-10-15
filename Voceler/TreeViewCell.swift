//
//  TreeViewCell.swift
//  Voceler
//
//  Created by 钟镇阳 on 8/21/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import SwiftString

class TreeViewCell: UITableViewCell {
    
    var arrow = UIImageView()
    var numOfChild:Int!
    
    func change(expand:Bool){
        if numOfChild > 0{
            UIView.animate(withDuration: 0.2, animations: {
                self.arrow.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI/2 * (expand ? 1 : 0)))
            })
        }
    }
    
    func setUp(level:Int, text:String, numOfChild:Int){
        self.numOfChild = numOfChild
        textLabel?.text = " ".times(3*level) + text
        if numOfChild > 0{
            arrow.image = #imageLiteral(resourceName: "forward-50")
        }
        else{
            arrow.image = #imageLiteral(resourceName: "horizontal_line-50")
        }
        contentView.addSubview(arrow)
        _ = arrow.sd_layout().rightSpaceToView(contentView, 10)?.widthIs(16)?.heightIs(16)?.centerYEqualToView(contentView)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
