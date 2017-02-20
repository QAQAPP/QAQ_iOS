//
//  NotificationVC.swift
//  QAQ
//
//  Created by Jiayang Miao on 2/14/17.
//  Copyright © 2017 Zhenyang Zhong. All rights reserved.
//

import UIKit
import SDAutoLayout
import FirebaseDatabase
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit
import TextFieldEffects

class NotificationVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var ref:FIRDatabaseReference!
    var textView:UITextView!
    var vc:UIViewController!
    
    let table = UITableView()
    
    let dictionary: [String: NotificationType] = [
        "questionAnswered": NotificationType.questionAnswered,
        "questionViewed": NotificationType.questionViewed,
        "answerChosen": NotificationType.answerChosen]
    
    var notificationsInDict:[String:AnyObject] = [:]
    var notifications:[NotificationModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setupProfile() // This is for..?
        
        currUser?.nRef.observe(FIRDataEventType.value, with: { (snapshot) in
            self.notificationsInDict = snapshot.value as! [String : AnyObject]
            print(self.notificationsInDict)
            self.loadNotificationsFromDict()
        })
        
        view.addSubview(table)
        _ = table.sd_layout().topSpaceToView(view, 0)?.bottomSpaceToView(view, 0)?.leftSpaceToView(view, 0)?.rightSpaceToView(view, 0)
        
        table.delegate = self
        table.dataSource = self
        table.register(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: "NotificationCell")
        table.separatorStyle = .none
        navigationBar.setColor(color: themeColor)
        //edgesForExtendedLayout = [.all]
        navigationItem.title = "Notifications"
        navigationController?.navigationBar.tintColor = themeColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadNotificationsFromDict () {
        self.notifications = []
        
        for thisNotificationInDict in notificationsInDict {
            print(thisNotificationInDict)
        }
        let thisNotification = NotificationModel()
        
        
        self.notifications.append(thisNotification)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)-> Int {
        return notifications.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        
        //cell.icon.image = notifications?[indexPath.row].user.profileImg
        
        cell.label.text = "This user liked your answer in Question"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // Implement later
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    

}
