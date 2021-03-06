//
//  InCollectionVC.swift
//  Voceler
//
//  Created by 钟镇阳 on 10/1/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import FirebaseDatabase

class InCollectionVC: UIViewController {
    
    private var parentVC:CollectionVC?
    private var questionView:QuestionView!
    private var qRef:FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        title = "In Collection"
    }
    
    func setup(parent:CollectionVC, qRef: FIRDatabaseReference){
        parentVC = parent
        questionView = Bundle.main.loadNibNamed("QuestionView", owner: self, options: nil)!.first as! QuestionView
        self.view.addSubview(questionView)
        _ = questionView.sd_layout().topSpaceToView(self.view, 0)?.bottomSpaceToView(self.view, 0)?.leftSpaceToView(self.view, 0)?.rightSpaceToView(self.view, 0)
        questionView.setup(parent: self, qRef: qRef)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !questionView.liked, let parent = parentVC{
//            if let index = questionManager?.qCollectionArr.index(of: currQuestion){
//                let cell = parent.table.cellForRow(at: IndexPath(row: index, section: 1)) as! CollectionCell
//                cell.isStared = questionView.liked
//            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        questionView.liked = true
    }
}
