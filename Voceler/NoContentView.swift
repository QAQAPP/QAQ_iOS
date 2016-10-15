//
//  NoContentView.swift
//  Voceler
//
//  Created by 钟镇阳 on 10/1/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import MJRefresh

class NoContentView: UIView {
    
    @IBOutlet weak var scroll: UIScrollView!
    var parent:QuestionVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let header = MJRefreshNormalHeader(refreshingBlock: {
            self.parent.nextContent()
            self.scroll.mj_header.endRefreshing()
        })!
        header.lastUpdatedTimeLabel.isHidden = true
        header.setTitle("Next question", for: .pulling)
        header.setTitle("Pull down to get next question", for: .idle)
        scroll.mj_header = header
    }
    
    func setupView(parent:QuestionVC){
        self.parent = parent
        parent.view.addSubview(self)
        _ = sd_layout().topSpaceToView(parent.view, 0)?.rightSpaceToView(parent.view, 0)?.leftSpaceToView(parent.view, 0)?.bottomSpaceToView(parent.view, 0)
    }
}
