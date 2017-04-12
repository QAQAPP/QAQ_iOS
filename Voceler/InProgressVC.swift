//
//  InProgressVC.swift
//  Voceler
//
//  Created by 钟镇阳 on 10/1/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import SCLAlertView
import UIViewController_NavigationBar
import FirebaseDatabase

class InProgressVC: UIViewController {
    
//    private var parentVC:CollectionVC?
    private var qRef:FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "In Progress"
        edgesForExtendedLayout = []
        navigationBar.setColor(color: themeColor)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(noGoodAnwser))
    }
    
    func noGoodAnwser(){
        let alert = SCLAlertView()
        _ = alert.addButton("Confirm", action: {
//            self.currQuestion.conclude()
            self.afterConclude()
        })
        _ = alert.showNotice("Conclusion", subTitle: "Are you sure you don't get a good answer?", closeButtonTitle: "Cancel")
    }
    
    func setup(parent:CollectionVC, qRef:FIRDatabaseReference){
        self.qRef = qRef
        let questionView = Bundle.main.loadNibNamed("QuestionView", owner: self, options: nil)!.first as! QuestionView
        self.view.addSubview(questionView)
        _ = questionView.sd_layout().topSpaceToView(self.view, 0)?.bottomSpaceToView(self.view, 0)?.leftSpaceToView(self.view, 0)?.rightSpaceToView(self.view, 0)
        questionView.setup(parent: self, qRef: qRef)
    }

//    func conclude(oid:String, cell:OptCell){
//        let alert = SCLAlertView()
//        _ = alert.addButton("Confirm", action: {
//            self.currQuestion.conclude(oid: oid)
//            self.afterConclude()
//        })
//        _ = alert.addButton("Cancel", action: {
//            cell.likeBtn.setImage(img: #imageLiteral(resourceName: "like"), color: darkRed)
//        })
////        alert.hideDefaultButton()
//        _ = alert.showNotice("Conclusion", subTitle: "Are you sure to conclude this question?", closeButtonTitle: "Cancel")
//    }
    
    func afterConclude(){
//        currUser!.qInProgress.append(qRef)
//        if let index = questionManager?.qInProgressArr.index(of: qRef)! {
//            questionManager?.qInProgressArr.remove(at: index)
//            currUser!.qCollection.append(qRef)
//            questionManager?.qCollectionArr.append(qRef)
//            controllerManager!.collectionVC.table.reloadData()
//            _ = self.navigationController?.popViewController(animated: true)
//        }
        
    }
}
