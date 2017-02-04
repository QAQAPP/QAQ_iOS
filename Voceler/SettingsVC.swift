//
//  SettingsVC.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 6/26/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import SDAutoLayout
import FirebaseDatabase
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit

class SettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let settingArr = ["Anonymous mode", "Auto Tags", "Bug Report", "Suggestions", "Join us", "Privacy Policy", "log out"]
    var ref:FIRDatabaseReference!
    var textView:UITextView!
    var vc:UIViewController!
    
    let table = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupProfile()
        view.addSubview(table)
        _ = table.sd_layout().topSpaceToView(view, 0)?.bottomSpaceToView(view, 0)?.leftSpaceToView(view, 0)?.rightSpaceToView(view, 0)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        navigationBar.setColor(color: themeColor)
        edgesForExtendedLayout = [.all]
        navigationItem.title = "Setting"
        navigationController?.navigationBar.tintColor = themeColor
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let text = settingArr[indexPath.row]
        cell.textLabel?.text = text
        if indexPath.row <= 1{
            let switcher = UISwitch()
            cell.addSubview(switcher)
            _ = switcher.sd_layout().topSpaceToView(cell, 8)?.rightSpaceToView(cell, 8)?.bottomSpaceToView(cell, 8)?.widthIs(52)
            switcher.addTarget(self, action: #selector(switcherTapped), for: .allEvents)
        }
        else if indexPath.row == settingArr.count - 1{
            cell.textLabel?.textColor = .red
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isSelected = false
        if indexPath.row == settingArr.count - 1{
            try! FIRAuth.auth()?.signOut()
            GIDSignIn.sharedInstance().signOut()
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            controllerManager = nil
            questionManager = nil
            dismiss(animated: true, completion: nil)
        }
        else if indexPath.row > 1{
            vc = UIViewController()
            vc.edgesForExtendedLayout = []
            textView = UITextView()
            textView.font = UIFont.systemFont(ofSize: 18)
            let view = vc.view
            view?.addSubview(textView)
            _ = textView.sd_layout().topSpaceToView(view, 0)?.rightSpaceToView(view, 0)?.leftSpaceToView(view, 0)?.bottomSpaceToView(view, 0)
            vc.title = settingArr[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
            if indexPath.row == 5{
                let path = Bundle.main.path(forResource: "privacy", ofType: "txt")
                let url = URL(fileURLWithPath: path!)
                textView.text = try! String(contentsOf: url)
                textView.isEditable = false
                textView.isSelectable = false
            }
            else{
                textView.text = ""
                textView.becomeFirstResponder()
                ref = FIRDatabase.database().reference().child(settingArr[indexPath.row])
                let btn = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(uploadText))
                vc.navigationItem.setRightBarButton(btn, animated: true)
            }
        }
    }
    
    func uploadText(){
        ref.child(currUser!.uid).setValue(textView.text)
        _ = vc.navigationController?.popViewController(animated: true)
    }
    
    func switcherTapped(){
//        appSetting.isAnonymous = switcher.isOn
    }
}
