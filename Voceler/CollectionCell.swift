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

class CollectionCell: UITableViewCell {
    @IBOutlet weak var starBtn: UIButton!
    @IBOutlet weak var badgeValue: BadgeSwift!
    @IBOutlet weak var detailLbl: UILabel!
    
    
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
                detailLbl?.text = question.qDescrption
            }
        }
    }
    var question:QuestionModel!
    var parentVC:CollectionVC!

    @IBAction func starAction(_ sender: AnyObject) {
        isStared = !isStared
    }
    
    func dislikeThisQuestion(){
        if let index = parentVC.qCollectionArr.index(of: question){
            parentVC.qCollectionArr.remove(at: index)
            parentVC.table.reloadData()
            question.removeFromCollection()
        }
        isStared = true
    }
    
    func setBtn() {
        starBtn.setImage(img: (isStared ? #imageLiteral(resourceName: "star_filled") : #imageLiteral(resourceName: "star")), color: darkRed)
    }
    
    
    func setup(parent:CollectionVC, question:QuestionModel){
        parentVC = parent
        self.question = question
        detailLbl?.text = question.qDescrption
        badgeValue.board(radius: 10.5, width: 0, color: .clear)
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
    }
    
}
