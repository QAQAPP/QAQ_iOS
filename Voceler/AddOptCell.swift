//
//  AddOptCell.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 7/7/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import GrowingTextViewHandler

class AddOptCell: UITableViewCell, UITextViewDelegate{

    @IBOutlet weak var textView: UITextView!
    var index:IndexPath!
    var parent:AskProblemVC!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    var handler:GrowingTextViewHandler!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textView.font = UIFont(name: "Helvetica Neue", size: 16)
        handler = GrowingTextViewHandler(textView: textView, withHeightConstraint: textViewHeight)
        textView.board(radius: 3, width: 1, color: .gray)
        textView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(textChange(noti:)), name: Notification.Name.UITextViewTextDidChange, object: textView)
    }
    
    func textChange(noti:Notification){
        handler.setText(textView.text, withAnimation: true)
        parent.optArr[index.row] = textView.text
        parent.cellHeightArr[index.row] = textViewHeight.constant + 8
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        parent.table.reloadRows(at: [index], with: .automatic)
    }
    
    override func cellHeight(for indexPath: IndexPath!, cellContentViewWidth width: CGFloat, tableView: UITableView!) -> CGFloat {
        super.cellHeight(for: indexPath, cellContentViewWidth: width, tableView: tableView)
        return textViewHeight.constant + 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
