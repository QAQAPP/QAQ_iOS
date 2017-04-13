//
//  CollectionCell.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 7/10/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import SDAutoLayout
import BadgeSwift
import FirebaseDatabase

class CollectionCell: UITableViewCell {
    @IBOutlet weak var starBtn: UIButton!
    @IBOutlet weak var badgeValue: BadgeSwift!
    @IBOutlet weak var detailLbl: UILabel!
    
    var qRef:FIRDatabaseReference!
    var timer:Timer?
    var isStared = true{
        didSet{
            setBtn()
            backgroundColor = (isStared ? .white : .lightGray)
            if !isStared{
                timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (timer) in
                    self.dislikeThisQuestion()
                }
                detailLbl?.text = "deleting..."
            }
            else{
                timer?.invalidate()
                timer = nil
            }
        }
    }
    var notiVal = 0{
        didSet{
            if notiVal > 0{
                self.badgeValue.text = String(notiVal)
                self.badgeValue.isHidden = false
            }
            else{
                self.badgeValue.isHidden = true
            }
        }
    }
    var parentVC:CollectionVC!

    @IBAction func starAction(_ sender: AnyObject) {
        isStared = !isStared
    }
    
    func dislikeThisQuestion(){
        if let index = questionManager?.qCollectionArr.index(of: qRef){
            questionManager?.qCollectionArr.remove(at: index)
            parentVC.table.reloadData()
        }
        isStared = true
    }
    
    func setBtn() {
        starBtn.setImage(img: (isStared ? #imageLiteral(resourceName: "star_filled") : #imageLiteral(resourceName: "star")), color: darkRed)
    }
    
    
    func setup(parent:CollectionVC, qRef:FIRDatabaseReference){
        parentVC = parent
        self.qRef = qRef
        badgeValue.board(radius: 10.5, width: 0, color: .clear)
        self.badgeValue.isHidden = true
        qRef.child("content").child("val").observe(.value, with: { (snapshot) in
            if let val = snapshot.value as? Int{
                self.notiVal = val
            }
        })
        qRef.child("content").child("description").observe(.value, with: { (snapshot) in
            if let text = snapshot.value as? String{
                self.detailLbl.text = text
            }
        })
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        _ = detailLbl?.sd_layout().rightSpaceToView(contentView, 35)
        starBtn.tintColor = pinkColor
        setBtn()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if selected{
//            question.clearNotiVal()
        }
    }
}
