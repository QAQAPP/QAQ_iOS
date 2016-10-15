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
    var email = ""
    var username:String?{
        didSet{
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: uid+"username")))
        }
    }
    var ref:FIRDatabaseReference!{
        didSet{
            ref.observe(.value, with:{ (snapshot) in
                if let userInfo = snapshot.value as? Dictionary<String,String>{
                    self.email = userInfo["email"]!
                    self.username = userInfo["username"]
                    if self.uid == currUser?.uid{
                        NotificationCenter.default.post(name: NSNotification.Name("UsernameLoaded"), object: self.username)
                    }
                    self.infoDic = userInfo
                    if let profileVC = self.profileVC{
                        profileVC.loadUserInfo()
                    }
                }
            })
        }
    }
    var qRef:FIRDatabaseReference!
    var storageRef:FIRStorageReference!
    var qInProgress = Array<String>() // Question in progress (contains QID)
    var qAsked = Array<String>() // Asked Question
    var qCollection = Array<String>() // Collected Question
    var infoDic = Dictionary<String,String>() // Basic info array
    var profileVC:ProfileVC?
    var profileImg:UIImage?
    var wallImg:UIImage?
    var qInProgressLimit = 5
    var qInCollectionLimit = 20
    
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
                NotificationCenter.default.post(name: NSNotification.Name(self.uid + "profile"), object: nil)
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
            questionManager.loadQuestionContent(qid: question, purpose: "qInProgressLoaded")
        }
        for question in qCollection{
            questionManager.loadQuestionContent(qid: question, purpose: "qCollectionLoaded")
        }
    }
    
    func collectQuestion(QID:String, like:Bool = true){
        currUser?.qRef.child(QID).setValue(like ? "liked" : nil)
    }
}
