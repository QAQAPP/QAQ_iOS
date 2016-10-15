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

class InProgressVC: UIViewController {
    
    private var parentVC:CollectionVC?
    private var currQuestion:QuestionModel!{
        didSet{
            let view = Bundle.main.loadNibNamed("QuestionView", owner: self, options: nil)!.first as! QuestionView
            view.setup(parent: self, question: currQuestion)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "In Progress"
        edgesForExtendedLayout = []
        navigationBar.setColor(color: themeColor)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Conclude", style: .plain, target: self, action: #selector(noGoodAnwser))
    }
    
    func noGoodAnwser(){
        let alert = SCLAlertView()
        _ = alert.addButton("Confirm", action: {
            self.currQuestion.conclude()
            self.afterConclude()
        })
        _ = alert.showNotice("Conclusion", subTitle: "Are you sure you don't get a good answer?", closeButtonTitle: "Cancel")
    }
    
    func setup(parent:CollectionVC, question:QuestionModel){
        currQuestion = question
        parentVC = parent
    }

    func conclude(OID:String, cell:CollectionViewCell){
        let alert = SCLAlertView()
        _ = alert.addButton("Confirm", action: {
            self.currQuestion.conclude(OID: OID)
            self.afterConclude()
        })
        _ = alert.addButton("Cancel", action: {
            cell.likeBtn.setImage(img: #imageLiteral(resourceName: "like"), color: darkRed)
        })
        alert.hideDefaultButton()
        _ = alert.showNotice("Conclusion", subTitle: "Are you sure to conclude this question?", closeButtonTitle: "Cancel")
    }
    
    private func afterConclude(){
        currUser!.qInProgress.append(currQuestion.QID)
        let index = parentVC!.qInProgressArr.index(of: currQuestion)!
        parentVC!.qInProgressArr.remove(at: index)
        currUser!.qCollection.append(currQuestion.QID)
        parentVC!.qCollectionArr.append(currQuestion)
        parentVC!.table.reloadData()
        _ = self.navigationController?.popViewController(animated: true)
    }
}
