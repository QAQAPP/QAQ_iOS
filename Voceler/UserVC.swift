//
//  UserVC.swift
//  QAQ
//
//  Created by Zhenyang Zhong on 2/2/17.
//  Copyright © 2017 Zhenyang Zhong. All rights reserved.
//

import UIKit

class UserVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoView: UIView!

    @IBAction func editAction(_ sender: Any) {
        
    }
    
    var thisUser:UserModel!{
        didSet{
            if let username = thisUser.username{
                usernameLabel.text = username
            }
            else{
                NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: thisUser.uid+"username"), object: self, queue: nil, using: { (noti) in
                    self.usernameLabel.text = self.thisUser.username!
                })
            }
            if let location = thisUser.location{
                locationLabel.text = location
            }
            else{
                NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: thisUser.uid+"location"), object: self, queue: nil, using: { (noti) in
                    self.locationLabel.text = self.thisUser.location!
                })
            }
            if thisUser.email != nil{
                emailLabel.text = thisUser.email
            }
            if let profileImage = thisUser.profileImg{
                profileImageView.image = profileImage
            }
            else{
                NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: thisUser.uid+"profile"), object: self, queue: nil, using: { (noti) in
                    self.usernameLabel.text = self.thisUser.username!
                })
            }
        }
    }
    
    let rowTitles = ["Collection", "Friends", "Setting"]
    let rowIcons = [#imageLiteral(resourceName: "Book-open - simple-line-icons"), #imageLiteral(resourceName: "People - simple-line-icons"), #imageLiteral(resourceName: "Wrench - simple-line-icons")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImageView.layer.cornerRadius = 80
        profileImageView.clipsToBounds = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "UserTableCell", bundle: nil), forCellReuseIdentifier: "UserTableCell")
        tableView.separatorColor = themeColor
        tableView.tableFooterView = UIView()
        infoView.layer.addBorder(edge: .bottom, color: themeColor, thickness: 2)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableCell") as! UserTableCell
        cell.icon.image = rowIcons[indexPath.row]
        cell.titleLabel.text = rowTitles[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
