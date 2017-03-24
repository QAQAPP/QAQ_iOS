//
//  User.swift
//  Voceler
//
//  Created by 钟镇阳 on 8/22/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseStorage

class UserModel: NSObject {
    var uid:String!
    var email:String?
    var inProgLimit:Int!
    var inCollectLimit:Int!
    var money = 0
    var username:String?{
        didSet{
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: uid+"username")))
        }
    }
    var location:String?{
        didSet{
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: uid+"location")))
        }
    }
    var ref:FIRDatabaseReference!{
        didSet{
            ref.child("money").observe(.value, with: { (snapshot) in
                if let money = snapshot.value as? Int{
                    self.money = money
                    if let uid = currUser?.uid, uid == self.uid{
                        controllerManager?.mainVC.scoreLabel.text = "$\(money/100)." + ((money%100 < 10) ? "0" : "") + "\(money%100)"
                    }
                }
                else{
                    self.ref.child("money").setValue(constantManager.base_money)
                }
            })
//            setup(child: "email")
//            setup(child: "username")
//            setup(child: "location")
//            setup(child: "qInProgressLimit", defaultVal: constantManager.in_process_limit)
            ref.observe(.value, with:{ (snapshot) in
                if let userInfo = snapshot.value as? Dictionary<String,Any>{
                    self.email = userInfo["email"] as? String
                    if let username = userInfo["username"] as? String{
                        self.username = username
                    }
                    self.location = userInfo["location"] as? String
                    if let qInProgressLimit = userInfo["qInProgressLimit"] as? Int{
                        self.qInProgressLimit = qInProgressLimit
                    }
                    else{
                        self.qInProgressLimit = 3
                    }
                    if let qInCollectionLimit = userInfo["qInCollectionLimit"] as? Int{
                        self.qInCollectionLimit = qInCollectionLimit
                    }
                    else{
                        self.qInCollectionLimit = 10
                    }
                    self.infoDic = userInfo
//                    if let profileVC = self.profileVC{
//                        profileVC.loadUserInfo()
//                    }
                    if let inProgLimit = userInfo["inProgLimit"] as? Int{
                        self.inProgLimit = inProgLimit
                    }
                    if let inCollectLimit = userInfo["inCollectLimit"] as? Int{
                        self.inCollectLimit = inCollectLimit
                    }
                }
            })
        }
    }
    var qRef:FIRDatabaseReference!
    
    // Reference to Notifications
    var nRef:FIRDatabaseReference!
    
    var storageRef:FIRStorageReference!
    var qInProgress = Array<String>() // Question in progress (contains QID)
    var qAsked = Array<String>() // Asked Question
    var qCollection = Array<String>() // Collected Question
    var infoDic = Dictionary<String,Any>() // Basic info array
//    var profileVC:ProfileVC?
    var profileImg:UIImage?
    var wallImg:UIImage?
    var qInProgressLimit:Int?
    var qInCollectionLimit:Int?
    
    private init(uid:String){
        self.uid = uid
    }
    
    func loadProfileImg(){
        if let img = memoryHandler.imageStorage[uid + "profile"]{
            profileImg = img
        }
        else{
            storageRef.child("profileImg.jpeg").data(withMaxSize: 1024*1024) { (data, error) in
                if let data = data{
                    self.profileImg = UIImage(data: data)
                }
                else {
                    self.profileImg = #imageLiteral(resourceName: "user-50")
                }
                memoryHandler.imageStorage[self.uid + "profile"] = self.profileImg
                let noti = Notification.Name(self.uid + "profile")
                NotificationCenter.default.post(name: noti, object: nil)
            }
        }
    }
    
    func loadWallImg(){
        if let img = memoryHandler.imageStorage[uid + "wall"]{
            wallImg = img
        }
        else {
            storageRef.child("wallImg.jpeg").data(withMaxSize: 1024*1024) { (data, error) in
                if let data = data{
                    self.wallImg = UIImage(data: data)
                }
                else {
                    self.wallImg = #imageLiteral(resourceName: "WallBG")
                }
                memoryHandler.imageStorage[self.uid + "wall"] = self.wallImg
                NotificationCenter.default.post(name: NSNotification.Name(self.uid + "wall"), object: nil)
            }
        }
    }
    
    static func getUser(uid:String, getWall:Bool = false, getProfile:Bool = false)->UserModel{
        let user = UserModel(uid: uid)
        let ref = FIRDatabase.database().reference().child("Users-v1").child(uid).child("info")
        user.storageRef = FIRStorage.storage().reference().child("Users").child(uid)
        user.setup(ref: ref)
        if getProfile {
            user.loadProfileImg()
        }
        if getWall{
            user.loadWallImg()
        }
        return user
    }
    
    func setup(ref:FIRDatabaseReference){
        self.ref = ref
        qRef = ref.parent?.child("Questions")
        // Reference to notification
        nRef = ref.parent?.child("notifications")
    }
    
    func loadCollection(){
        qRef.observe(.value, with: { (snapshot) in
            self.qInProgress.removeAll()
            self.qCollection.removeAll()
            if let dict = snapshot.value as? Dictionary<String, String>{
                for (qid, val) in dict{
                    if val == "In progress"{
                        self.qInProgress.append(qid)
                    }
                    else if val == "liked"{
                        self.qCollection.append(qid)
                    }
                }
                self.loadCollectionDetail()
            }
        })
    }
    
    func loadCollectionDetail(){
        for question in qInProgress{
            questionManager?.loadQuestionContent(qid: question, purpose: "qInProgressLoaded")
        }
        for question in qCollection{
            questionManager?.loadQuestionContent(qid: question, purpose: "qCollectionLoaded")
        }
    }
    
    func collectQuestion(qid:String, like:Bool = true){
        currUser?.qRef.child(qid).setValue(like ? "liked" : nil)
    }
    
    func setup(child:String, defaultVal:Any? = nil){
        ref.child(child).observe(.value, with: { (snap) in
            if let val = snap.value{
                self.setValue(val, forKey: child)
            }
            else if let val = defaultVal{
                self.setValue(val, forKey: child)
            }
        })
    }
}
