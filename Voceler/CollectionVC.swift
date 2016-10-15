//
//  CollectionVC.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 6/26/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import MJRefresh
import FirebaseDatabase

class CollectionVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // UIVars
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var table: UITableView!
    
    // FieldVars
    var qInProgressArr = Array<QuestionModel>()
    var qCollectionArr = Array<QuestionModel>()
    
    // Actions
    func detailAction(indexPath:IndexPath){
        
    }
    // Functions
    func loadCollections(){
        currUser?.loadCollectionDetail()
        _ = NotificationCenter.default.addObserver(forName: NSNotification.Name("qInProgressLoaded"), object: nil, queue: nil, using:{ (noti) in
            if let dict = noti.object as? Dictionary<String, Any>{
                let qid = dict["qid"] as! String
                self.load(qid: qid, dict: dict, inProgress: true)
            }
        })
        _ = NotificationCenter.default.addObserver(forName: NSNotification.Name("qCollectionLoaded"), object: nil, queue: nil, using: { (noti) in
            if let dict = noti.object as? Dictionary<String, Any>{
                let qid = dict["qid"] as! String
                self.load(qid: qid, dict: dict, inProgress: false)
            }
        })
    }
    
    func load(qid:String, dict:Dictionary<String, Any>, inProgress:Bool){
        if inProgress{
            if currUser!.qInProgress.contains(qid){
                for question in self.qInProgressArr{
                    if question.QID == qid{
                        table.mj_header.endRefreshing()
                        return
                    }
                }
                let question = questionManager.getQuestion(qid: qid, question: dict)!
                self.qInProgressArr.append(question)
            }
        }
        else{
            if currUser!.qCollection.contains(qid){
                for question in self.qCollectionArr{
                    if question.QID == qid{
                        table.mj_header.endRefreshing()
                        return
                    }
                }
                let question = questionManager.getQuestion(qid: qid, question: dict)!
                self.qCollectionArr.append(question)
            }
        }
        self.table.reloadData()
        table.mj_header.endRefreshing()
    }
    
    // Override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupProfile()
        navigationBar.setColor(color: themeColor)
        table.delegate = self
        table.dataSource = self
        table.register(UINib(nibName: "CollectionCell", bundle: nil), forCellReuseIdentifier: "CollectionCell")
        let header = MJRefreshNormalHeader(refreshingBlock: {
            currUser?.loadCollectionDetail()
            if currUser!.qInProgress.isEmpty && currUser!.qCollection.isEmpty{
                self.table.mj_header.endRefreshing()
            }
        })!
        header.lastUpdatedTimeLabel.isHidden = true
        header.setTitle("Refresh", for: .pulling)
        header.setTitle("Pull down to refresh", for: .idle)
        table.mj_header = header
        loadCollections()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return qInProgressArr.count
        }
        else{
            return qCollectionArr.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "In progress"
        }
        else {
            return "Collection"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCell") as! CollectionCell
        if indexPath.section == 0{
            cell.starBtn.isHidden = true
            cell.setup(parent: self, question: qInProgressArr[indexPath.row])
        }
        else{
            cell.starBtn.isHidden = false
            cell.setup(parent: self, question: qCollectionArr[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        table.cellForRow(at: indexPath)?.isSelected = false
        if indexPath.section == 0{
            let question = qInProgressArr[indexPath.row]
            let vc = InProgressVC()
            vc.setup(parent: self, question: question)
            show(vc, sender: self)
        }
        else{
            let cell = table.cellForRow(at: indexPath) as! CollectionCell
            if cell.isStared{
                let question = qCollectionArr[indexPath.row]
                let vc = InCollectionVC()
                vc.setup(parent: self, question: question)
                show(vc, sender: self)
            }
            else{
                cell.isStared = true
            }
        }
    }
    
    override func hasCustomNavigationBar() -> Bool {
        return true
    }
}
