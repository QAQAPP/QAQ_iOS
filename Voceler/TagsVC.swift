//
//  TagsVC.swift
//  Voceler
//
//  Created by 钟镇阳 on 9/18/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit

class TagsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func rightBarButtonClicked(){
        print("Right button clicked")
    }
    
    func setupUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(rightBarButtonClicked))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}
