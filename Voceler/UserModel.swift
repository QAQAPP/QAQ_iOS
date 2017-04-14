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
import FirebaseAuth

class UserModel: NSObject {
    var email:String?{
        didSet{
            userVC?.emailLabel.text = email
        }
    }
    var inProgLimit:Int?
    var inCollectLimit:Int?
    var money:Int?{
        didSet{
            controllerManager?.mainVC.scoreLabel.text = "$\(money!/100)." + ((money!%100 < 10) ? "0" : "") + "\(money!%100)"
        }
    }
    var username:String?{
        didSet{
            userVC?.usernameLabel.text = username
        }
    }
    var location:String?{
        didSet{
            userVC?.locationLabel.text = location
        }
    }
    var ref:FIRDatabaseReference!
    var qRef:FIRDatabaseReference!
    var uRef:FIRDatabaseReference!
    // Reference to Notifications
    var nRef:FIRDatabaseReference!
    
    var storageRef:FIRStorageReference!
//    var qInProgress = Array<FIRDatabaseReference>() // Question in progress (contains QID)
//    var qCollection = Array<FIRDatabaseReference>() // Collected Question
    var profileImg = #imageLiteral(resourceName: "user-50"){
        didSet{
            userVC?.profileImageView.image = profileImg
        }
    }
    var qInProgressLimit:Int?
    var qInCollectionLimit:Int?
    weak var userVC:UserVC?

    init(ref:FIRDatabaseReference, userVC:UserVC?){
        self.ref = ref
        qRef = ref.child("Questions")
        nRef = ref.child("notifications")
        uRef = ref.child("info")
        self.userVC = userVC
    }
    
    func setup(){
        uRef.child("username").observe(.value, with: { (snapshot) in
            if let username = snapshot.value as? String{
                self.username = username
            }
            else{
                self.username = "username"
            }
        })
        uRef.child("email").observe(.value, with: { (snapshot) in
            if let email = snapshot.value as? String{
                self.email = email
            }
            else{
                self.email = "email"
            }
        })
        uRef.child("location").observe(.value, with: { (snapshot) in
            if let location = snapshot.value as? String{
                self.location = location
            }
            else{
                self.location = "location"
            }
        })
        storageUserRef.child(ref.key).child("profileImg.jpeg").data(withMaxSize: 1024*1024) { (data, error) in
            if let data = data, let image = UIImage(data: data){
                self.profileImg = image
            }
            else{
                self.profileImg = #imageLiteral(resourceName: "user-50")
            }
        }
    }
}
