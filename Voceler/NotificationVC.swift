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
    
    let NTypeLookup: [String: NotificationType] = [
        "questionAnswered": NotificationType.questionAnswered,
        "questionViewed": NotificationType.questionViewed,
        "answerChosen": NotificationType.answerChosen]
    
    var notificationsInDict:[String:AnyObject] = [:]
    var notifications:[NotificationModel] = []
    
    convenience init() {
        self.init(nibName:nil, bundle:nil)
        
        currUser?.nRef.observe(FIRDataEventType.value, with: { (snapshot) in
            if let notiInfo = snapshot.value as? [String : AnyObject]{
                self.notificationsInDict = notiInfo as! [String : AnyObject]
                print(self.notificationsInDict)
            }
            //
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadNotificationsFromDict()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setupProfile() // This is for..?
        /*
        currUser?.nRef.observe(FIRDataEventType.value, with: { (snapshot) in
            self.notificationsInDict = snapshot.value as! [String : AnyObject]
            print(self.notificationsInDict)
            self.loadNotificationsFromDict()
        })
        */
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
    
    func loadNotificationsFromDict () {
        self.notifications = []
        
        for thisNotificationInDict in notificationsInDict {
            print(thisNotificationInDict)
            let thisNotification = NotificationModel(thisNotificationInDict.value["qid"] as! String,
                of: NTypeLookup[thisNotificationInDict.value["type"] as! String]!,
                with: thisNotificationInDict.value["details"] as AnyObject,
                whether: thisNotificationInDict.value["viewed"] as! Bool,
                on: thisNotificationInDict.key )
            self.notifications.append(thisNotification)
        }
        
        self.table.reloadData()
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
        let thisNotification = notifications[indexPath.row]
        
        questionManager?.loadQuestionContent(qid: thisNotification.qid)
        
        /*NotificationCenter.default.addObserver(forName: NSNotification.Name(thisNotification.qid+"question"), queue: nil, using: { (noti) in
            if (thisQuesiton != nil) {
                print((thisQuestion as! QuestionModel).QID)
            }

        })*/

        switch thisNotification.type {
        case NotificationType.questionAnswered:
            print(thisNotification.details)
            
            let user = UserModel.getUser(uid: thisNotification.details)
            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: thisNotification.details+"username"), object: nil, queue: nil, using: { (noti) in
                if let username = user.username{
                    cell.label.text = "\(username) answered your question: ..."
                }
            })
            
        case NotificationType.questionViewed:
            let views = thisNotification.details
            
            cell.label.text = "You got \(views) views for your question: ..."
            
        case NotificationType.answerChosen:
            print(thisNotification.details)
            
            let user = UserModel.getUser(uid: thisNotification.details)
            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: thisNotification.details+"username"), object: nil, queue: nil, using: { (noti) in
                if let username = user.username{
                    cell.label.text = "Your answer was chosen by \(username) in question: ..."
                }
            })
            
        }
        
        if thisNotification.viewed == false {
            cell.backgroundColor = UIColor.red // maybe its too aggressive
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // Navigate to question view - Implement later
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
