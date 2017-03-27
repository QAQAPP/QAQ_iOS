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

//    var ref:FIRDatabaseReference!
    
    let table = UITableView()
    
    var notViewedCount = 0 {
        didSet{
            controllerManager?.userVC.setupBadgeValueForNotificationCell()
        }
    }
    
    let NTypeLookup: [String: NotificationType] = [
        "questionAnswered": NotificationType.questionAnswered,
        "questionViewed": NotificationType.questionViewed,
        "questionConcluded": NotificationType.questionConcluded]
    
    var notificationsInDict:[String:AnyObject] = [:]
    var notifications:[NotificationModel] = []
    
    convenience init() {
        self.init(nibName:nil, bundle:nil)
        // Firebase connection
        currUser?.nRef.observe(FIRDataEventType.value, with: { (snapshot) in
            if let notiInfo = snapshot.value as? [String : AnyObject]{
                self.notificationsInDict = notiInfo
                // Parse notification data into NotificationModels
                self.loadNotificationsFromDict()
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(table)
        _ = table.sd_layout().topSpaceToView(view, 0)?.bottomSpaceToView(view, 0)?.leftSpaceToView(view, 0)?.rightSpaceToView(view, 0)
        
        setupProfile() // This is for..?
        table.delegate = self
        table.dataSource = self
        table.register(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: "NotificationCell")
        table.separatorStyle = .none
        navigationBar.setColor(color: themeColor)
        //edgesForExtendedLayout = [.all]
        navigationItem.title = "Notifications"
        navigationController?.navigationBar.tintColor = themeColor
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func loadNotificationsFromDict () {
        self.notifications.removeAll()
        self.notViewedCount = 0
        
        for thisNotificationInDict in notificationsInDict {
            print("NotificationInDict: ", thisNotificationInDict)
            
            let thisNotification = NotificationModel(thisNotificationInDict.value["qid"] as! String,
                of: NTypeLookup[thisNotificationInDict.value["type"] as! String]!,
                with: thisNotificationInDict.value["details"] as AnyObject,
                whether: thisNotificationInDict.value["viewed"] as! Bool,
                on: thisNotificationInDict.key )
            
            if (thisNotification.viewed == false) {
                self.notViewedCount += 1
            }
            
            self.notifications.append(thisNotification)
            
            // If it is a concluded type notification then load the content of question
            if thisNotification.type == NotificationType.questionConcluded {
                
                print("Loading concluded question", thisNotification.qid)
                
                questionManager?.loadQuestionContent(qid: thisNotificationInDict.value["qid"] as! String, purpose: "qConcludedLoaded")
                
                _ = NotificationCenter.default.addObserver(forName: NSNotification.Name("qConcludedLoaded"), object: nil, queue: nil, using:{ (noti) in
                    print("Observed object")
                    if let dict = noti.object as? Dictionary<String, Any>{
                        let qid = dict["qid"] as! String
                        print(qid)
                        self.loadConcludedQuestion(qid: qid, dict: dict)
                    }
                })
            }
            
        }
        
        self.notifications.sort { $0.timestamp > $1.timestamp }
        self.table.reloadData()
    }
    
    func loadConcludedQuestion(qid:String, dict:Dictionary<String, Any>) {
        if let question = questionManager?.getQuestion(qid: qid, question: dict){
            // Question is loaded here
            controllerManager?.collectionVC?.qConcludedArr.append(question)
            print("Loaded concluded question", question.qid)
            self.table.reloadData()
        }
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
        
        //questionManager?.loadQuestionContent(qid: thisNotification.qid)
        let thisQuestionModel = controllerManager?.collectionVC.findQuestionModel(with: thisNotification.qid)

        switch thisNotification.type {
        case NotificationType.questionAnswered:
            let user = UserModel.getUser(uid: thisNotification.details)
            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: thisNotification.details+"username"), object: nil, queue: nil, using: { (noti) in
                if let username = user.username{
                    cell.label.text = "\(username) answered your question \((thisQuestionModel?.qDescrption)!)"
                }
            })

        case NotificationType.questionViewed:
            let views = thisNotification.details
            cell.label.text = "You got \(views) views for your question \((thisQuestionModel?.qDescrption)!)"
            
        case NotificationType.questionConcluded:
            let user = UserModel.getUser(uid: thisNotification.details)
            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: thisNotification.details+"username"), object: nil, queue: nil, using: { (noti) in
                if let username = user.username{
                    //print((thisQuestionModel?.qDescrption)!)
//                    cell.label.text = "Your answer was accepted by \(username) in question \((thisQuestionModel?.qDescrption)!)"
                    cell.label.text = "Your answer was accepted by \(username)"
                }
            })
        }

        // Unread notifications have gray backgrounds
        if thisNotification.viewed == false {
            cell.backgroundColor = UIColor(red: 225, green: 225, blue: 225)
            cell.textLabel?.textColor = UIColor.black
        } else {
            cell.backgroundColor = UIColor.white
            cell.textLabel?.textColor = UIColor.gray
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let thisNotification = notifications[indexPath.row]
        showNotification(qid: thisNotification.qid, nid: thisNotification.timestamp)
    }
    
    func showNotification(qid QID:String, nid NID:String) {
        updateViewedStatus(of: NID)
        showQuestionVC(of: QID)
    }
    
    func showQuestionVC(of QID:String) {
        var inProgress = true
        var thisQuestionModel = controllerManager?.collectionVC.findQuestionModel(with: QID, from: true)
        //print(thisQuestionModel?.qDescrption)
        if (thisQuestionModel == nil) {
            thisQuestionModel = controllerManager?.collectionVC.findQuestionModel(with: QID, from: false)
            //print(thisQuestionModel?.qDescrption)
            inProgress = false
        }
        // In current design thisQuestionModel must exist in either InProgress or Collection/Concluded List
        if (inProgress == true) {
            let thisQuestionVC = InProgressVC()
            thisQuestionVC.setup(parent:controllerManager!.collectionVC!, question:thisQuestionModel!)
            show(thisQuestionVC, sender: self)
        } else {
            let thisQuestionVC = InCollectionVC()
            thisQuestionVC.setup(parent:controllerManager!.collectionVC!, question:thisQuestionModel!)
            show(thisQuestionVC, sender: self)
        }
    }
    
    func findQID(with timestamp:String) -> String? {
        self.loadNotificationsFromDict()
        for thisNotification in notifications {
            if thisNotification.timestamp == timestamp {
                return thisNotification.qid
            }
        }
        return nil
    }
    
    func updateViewedStatus(of notification:String) {
        currUser?.nRef.child(notification).child("viewed").setValue(true)
        table.reloadData()
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
