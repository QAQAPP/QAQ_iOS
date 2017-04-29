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
import SDAutoLayout

class CollectionVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // UIVars
//    @IBOutlet weak var searchBar: UISearchBar!
//    @IBOutlet weak var table: UITableView!
    let table = UITableView()
    var didLoad = false
    

    func generateQInProgressValue() -> Int{
        var val = 0
        for q in (questionManager?.qInProgressArr)! {
            val += q.child("content").value(forKey: "val") as! Int
        }
        return val
    }
    
    // Override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.didLoad = true

        view.addSubview(table)
        _ = table.sd_layout().topSpaceToView(view, 0)?.leftSpaceToView(view, 0)?.rightSpaceToView(view, 0)?.bottomSpaceToView(view, tabBarHeight())
        
        navigationItem.title = "My Questions"
        navigationController?.navigationBar.tintColor = themeColor
        edgesForExtendedLayout = [.all]
//        setupProfile()
        table.separatorStyle = .none
        table.delegate = self
        table.dataSource = self
        table.register(UINib(nibName: "CollectionCell", bundle: nil), forCellReuseIdentifier: "CollectionCell")
//        let header = MJRefreshNormalHeader(refreshingBlock: {
////            currUser?.loadCollectionDetail()
//            if currUser!.qInProgress.isEmpty && currUser!.qCollection.isEmpty{
//                self.table.mj_header.endRefreshing()
//            }
//        })!
//        header.lastUpdatedTimeLabel.isHidden = true
//        header.setTitle("Refresh", for: .pulling)
//        header.setTitle("Pull down to refresh", for: .idle)
//        table.mj_header = header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return questionManager!.qInProgressArr.count
        }
        else{
            return questionManager!.qCollectionArr.count
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
            cell.setup(parent: self, qRef: questionManager!.qInProgressArr[indexPath.row])
        }
        else{
            cell.starBtn.isHidden = false
            cell.setup(parent: self, qRef: questionManager!.qCollectionArr[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        table.cellForRow(at: indexPath)?.isSelected = false
        if indexPath.section == 0{
            if let qRef = questionManager?.qInProgressArr[indexPath.row]{
                let vc = InProgressVC()
                vc.setup(parent: self, qRef: qRef)
                show(vc, sender: self)
            }
        }
        else{
            let cell = table.cellForRow(at: indexPath) as! CollectionCell
            if cell.isStared{
                if let qRef = questionManager?.qCollectionArr[indexPath.row]{
                    let vc = InCollectionVC()
                    vc.setup(parent: self, qRef: qRef)
                    show(vc, sender: self)
                }
            }
            else{
                cell.isStared = true
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
