//
//  UserVC.swift
//  QAQ
//
//  Created by Zhenyang Zhong on 2/2/17.
//  Copyright © 2017 Zhenyang Zhong. All rights reserved.
//

import UIKit

class UserVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoView: UIView!
    
    var thisUser:UserModel!
    
    let rowTitles = ["Collection", "Message", "Setting"]
    let rowIcons = [#imageLiteral(resourceName: "Book-open - simple-line-icons"), #imageLiteral(resourceName: "message-32"), #imageLiteral(resourceName: "Wrench - simple-line-icons")]
    
    func profileTapped(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let pickupPhotos = UIAlertAction(title: "Select photo", style: .destructive) { (action) in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            self.show(imagePicker, sender: self)
        }
        alert.addAction(pickupPhotos)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImageView.layer.cornerRadius = 80
        profileImageView.clipsToBounds = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "UserTableCell", bundle: nil), forCellReuseIdentifier: "UserTableCell")
        tableView.separatorStyle = .none
        if thisUser == currUser{
            let tap = UITapGestureRecognizer(target: self, action: #selector(profileTapped))
            profileImageView.addGestureRecognizer(tap)
            infoView.addGestureRecognizer(tap)
        }
        loadUserInfo()
    }
    
    func loadUserInfo(){
        thisUser.ref.child("username").observe(.value, with: { (snap) in
            if let val = snap.value as? String{
                self.usernameLabel.text = val
            }
        })
        thisUser.ref.child("location").observe(.value, with: { (snap) in
            if let val = snap.value as? String{
                self.locationLabel.text = val
            }
        })
        thisUser.ref.child("email").observe(.value, with: { (snap) in
            if let val = snap.value as? String{
                self.emailLabel.text = val
            }
        })
        thisUser.storageRef.child("profileImg.jpeg").data(withMaxSize: 1024*1024) { (data, error) in
            if let data = data{
                self.profileImageView.image = UIImage(data: data)
            }
            else {
                self.profileImageView.image = #imageLiteral(resourceName: "user-50")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return thisUser == currUser ? rowTitles.count : rowTitles.count - 2
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isSelected = false
        if indexPath.row == 0{
            navigationController?.pushViewController(controllerManager!.collectionVC, animated: true)
        }
        else if indexPath.row == 1{
            navigationController?.pushViewController(controllerManager!.notificationVC, animated: true)
        }
        else if indexPath.row == 2{
            navigationController?.pushViewController(controllerManager!.settingsVC, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true) {
            self.profileImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
            currUser?.storageRef.child("profileImg.jpeg").put(self.profileImageView.image!.dataAtMost(bytes: 100*1024))
        }
    }
    
    func pushNotificationView() -> () {
        navigationController?.pushViewController(controllerManager!.notificationVC, animated: true)
    }
}
