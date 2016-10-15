//
//  OptCell.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 6/27/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import FoldingCell
import SDAutoLayout

class OptCell: FoldingCell, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var likeBtn: UIImageView!
    @IBOutlet weak var numOfLike: UILabel!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var textLbl: UILabel!
    @IBOutlet weak var contentTF: UITextView!
    @IBOutlet weak var contentCV: UIView!
    @IBOutlet weak var userTBV: UITableView!
    @IBOutlet weak var moreImg: UIImageView!
    @IBOutlet weak var reportImg: UIImageView!
    @IBOutlet weak var numOfLikeWidth: NSLayoutConstraint!
    @IBOutlet weak var reportView: UIView!
    @IBOutlet weak var moreView: UIView!
    
    var tableView: UITableView!
    var indexPath: IndexPath!
    var parent: QuestionVC!
    
    @IBOutlet weak var textViewToBottom: NSLayoutConstraint!
    
    func setUp(parent:QuestionVC, tbv:UITableView, row:IndexPath, color:UIColor, foreViewText:String, num:Int, contentViewText:String, isInCollection:Bool = false) {
        self.parent = parent
        contentCV.isHidden = true
        textViewToBottom.constant = 0
        
        tableView = tbv
        indexPath = row
        textLbl.text = foreViewText
        numOfLike.text = String(num)
        
        containerView.board(radius: 5, width: 1, color: UIColor(cgColor: containerView.layer.borderColor!))
        foregroundView.board(radius: 5, width: 1, color: UIColor(cgColor: foregroundView.layer.borderColor!))
        likeBtn.setIcon(img: #imageLiteral(resourceName: "checked_2-50"), color: pinkColor)
        controlView.backgroundColor = lightGray
        controlView.board(radius: 0, width: 1, color: .black)
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeAction))
        controlView.addGestureRecognizer(tap)
        let textTap = UITapGestureRecognizer(target: self, action: #selector(textTapped))
        textLbl.addGestureRecognizer(textTap)
        contentTF.text = contentViewText
        contentCV.backgroundColor = lightGray
        contentCV.board(radius: 0, width: 1, color: .black)
        let contentTap = UITapGestureRecognizer(target: self, action: #selector(textTapped))
        contentTF.addGestureRecognizer(contentTap)
        contentTF.font = UIFont(name: "Helvetica Neue", size: 16)
        textLbl.font = UIFont(name: "Helvetica Neue", size: 16)
        
        userTBV.register(UINib(nibName: "UserListCell", bundle: nil), forCellReuseIdentifier: "UserListCell")
        userTBV.delegate = self
        userTBV.dataSource = self
        userTBV.separatorStyle = .none
        userTBV.board(radius: 0, width: 1, color: .black)
        
        moreImg.setIcon(img: #imageLiteral(resourceName: "more-50"), color: .black)
        reportImg.setIcon(img: #imageLiteral(resourceName: "police-50"), color: .black)
        
        if isInCollection{
            likeBtn.isHidden = true
            _ = numOfLike.sd_layout().rightSpaceToView(controlView, 8)
            numOfLikeWidth.constant = 80
        }
    }

    func likeAction(){
        likeBtn.setIcon(img: #imageLiteral(resourceName: "checked_2_filled-25"), color: pinkColor)
    }
    
    func textTapped() {
        tableView.delegate!.tableView!(tableView, didSelectRowAt: indexPath)
    }
    
    override func animationDuration(_ itemIndex:NSInteger, type:AnimationType)-> TimeInterval {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserListCell")!
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        parent.showAskerInfo()
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }
}
