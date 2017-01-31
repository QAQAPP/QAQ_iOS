//
//  AskProblemVC.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 6/30/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import GrowingTextViewHandler_Swift
import BFPaperButton
import SwiftString3
import SCLAlertView
import Networking
import SwiftSpinner

class AskProblemVC: UIViewController, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate{
    // UIVars
    @IBOutlet weak var heightTV: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var scroll: UIScrollView!
    
    @IBOutlet weak var contentView: UIView!
    
    var table:UITableView!
    
    // FieldVars
    var optArr = [String]()
    var cellHeightArr = [CGFloat]()
    var handler:GrowingTextViewHandler!
    var text:String?
    var parentVC:AskProblemVC?
    var indexPath:IndexPath?
    
    // Actions
    func textChange(noti:Notification) {
        handler.resizeTextView(true)
    }
    
    func cancelAction() {
        dismiss(animated: true, completion: nil)
    }
    
    func addAction(){
        let board = UIStoryboard(name: "Main", bundle: nil)
        let vc = board.instantiateViewController(withIdentifier: "Ask Question") as! AskProblemVC
        let nav = UINavigationController(rootViewController: vc)
        vc.navigationItem.title = "Option"
        nav.navigationBar.setColor(color: themeColor)
        vc.parentVC = self
        show(nav, sender: self)
    }
    
    func editAction(indexPath:IndexPath){
        let board = UIStoryboard(name: "Main", bundle: nil)
        let vc = board.instantiateViewController(withIdentifier: "Ask Question") as! AskProblemVC
        let nav = UINavigationController(rootViewController: vc)
        vc.navigationItem.title = "Option"
        nav.navigationBar.setColor(color: themeColor)
        vc.text = optArr[indexPath.row]
        vc.parentVC = self
        vc.indexPath = indexPath
        show(nav, sender: self)
    }
    
    func textReset(indexPath:IndexPath, text:String){
        optArr[indexPath.row] = text
        table.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func addOpt() {
        table.endEditing(true)
        optArr.append("")
        cellHeightArr.append(42)
        table.reloadData()
        let cell = table.cellForRow(at: IndexPath(row: optArr.count-1, section: 0)) as! AddOptCell
        cell.textView.becomeFirstResponder()
    }
    
    func nextAction(){
        if textView.text.length < 10{
            _ = SCLAlertView().showError("Sorry", subTitle: "The question description should be at least 10 characters long.")
        }
        else{
            if var text = textView.text{
                text += ". " + optArr.joined(separator: ". ")
                networkingManager?.getQuestionTags(text: text)
                SwiftSpinner.show("Analysing Question...")
            }
            else{
                let vc = controllerManager!.tagsVC
                vc.setQuestion(descr: self.textView.text, optArr: self.optArr, tags: nil)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    // Functions
    func setupUI() {
        let notiCenter = NotificationCenter.default
        notiCenter.addObserver(self, selector: #selector(textChange(noti:)), name: Notification.Name.UITextViewTextDidChange, object: textView)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(addOpt))
        edgesForExtendedLayout = []
        textView.text = ""
        textView.becomeFirstResponder()
        
        handler = GrowingTextViewHandler(textView: textView, heightConstraint: heightTV)
//        handler.updateMinimumNumber(ofLines: 1, andMaximumNumberOfLine: 10)
        handler.minimumNumberOfLines = 1
        handler.maximumNumberOfLines = 10
        scroll.delegate = self
        
        let rightBtn = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextAction))
        navigationItem.rightBarButtonItem = rightBtn
        
        // Setup Table
        table = UITableView()
        contentView.addSubview(table)
        _ = table.sd_layout()
            .topSpaceToView(textView, 2)!
            .leftSpaceToView(contentView, 0)!
            .rightSpaceToView(contentView, 0)!
            .bottomSpaceToView(contentView, 0)!
        _ = table.addBorder(edges: .top, colour: .black, thickness: 2)
        _ = textView.addBorder(edges: .bottom, colour: .black)
        table.delegate = self
        table.dataSource = self
        table.register(UINib(nibName: "AddOptCell", bundle: nil), forCellReuseIdentifier: "AddOptCell")
        navigationBar.setColor(color: themeColor)
        table.tableFooterView = UIView()
        table.separatorStyle = .none
        
        textView.becomeFirstResponder()
    }
    
    // Override functions    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.TagsLoaded, object: nil, queue: nil, using: { (noti) in
            SwiftSpinner.hide()
            let vc = controllerManager!.tagsVC
            vc.setQuestion(descr: self.textView.text, optArr: self.optArr, tags: noti.object as? [String])
            self.navigationController?.pushViewController(vc, animated: true)
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        textView.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let text = text {
            handler.setText(text, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return optArr.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if indexPath.row == optArr.count{
            let cell = UITableViewCell()
            cell.textLabel?.text = "Add an Option"
            cell.textLabel?.textColor = .gray
            cell.backgroundColor = .lightGray
            cell.textLabel?.textAlignment = .center
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddOptCell") as! AddOptCell
            cell.textView.text = optArr[indexPath.row]
            cell.parent = self
            cell.index = indexPath
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == optArr.count{
            return 42
        }
        else {
            return cellHeightArr[indexPath.row]
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isSelected = false
        if indexPath.row == optArr.count{
            addOpt()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        tableView.endEditing(true)
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            self.optArr.remove(at: indexPath.row)
            self.cellHeightArr.remove(at: indexPath.row)
            tableView.reloadData()
        }
        return [deleteAction]
    }
}
