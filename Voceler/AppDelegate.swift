//
//  AppDelegate.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 6/21/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
import Networking
import GoogleSignIn
import SDAutoLayout
import FBSDKLoginKit
import UserNotifications
import FirebaseMessaging
import FirebaseDatabase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        // Override point for customization after application launch.
        FIRApp.configure()
        IQKeyboardManager.sharedManager().enable = true
        connectToFcm()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        window?.backgroundColor = .white
        constantManager.setup()
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 data message (sent via FCM)
            FIRMessaging.messaging().remoteMessageDelegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()

        // Use this Token to send specific notification to certain device
        
//        if #available(iOS 10.0, *) {
//            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { (granted, error) in
//                if granted{
//                    print("Grant successfully")
//                }
//                else if let error = error{
//                    print(error.localizedDescription)
//                }
//            })
//        } else {
//            // Fallback on earlier versions
//            let notiTypes:UIUserNotificationType = [.alert, .badge, .sound]
//            let notiSettings = UIUserNotificationSettings(types: notiTypes, categories: nil)
//            UIApplication.shared.registerUserNotificationSettings(notiSettings)
//        }
//        
        
//        _ = questionManager.getQuestion()
//        let networking = Networking(baseURL: "http://45.55.110.230:3000/v1")
//        networking.authenticate(headerKey: "uid", headerValue: "6Z6TrOaxPkWG9OaInB0x3k6mir73")
//        networking.authenticate(headerKey: "token", headerValue: "、")
//        networking.GET("/posts") { (JSON, error) in
//            print(JSON)
//            print(error)
//        }
//        let ref = FIRDatabase.database().reference().child("Questions")
//        ref.queryStarting(atValue: "-KSVI47OyTCRjWnuk4RJ").observeSingleEvent(of: .value, with:
//            { (snapshot) in
//                print(snapshot.value)
//        })
//
//        let arr = ["a","b","c","d"]
//        ref.child("Array").setValue(arr)
//        ref.child("Dict").setValue(["hello":"World", "Java":"Python"])
//        ref.child("0").runTransactionBlock({ (data) -> FIRTransactionResult in
//            print(data.value)
//            let result = FIRTransactionResult.success(withValue: data)
//            return result
//            }, andCompletionBlock: { (error, bool, snapshot) in
//            print(snapshot?.value)
//        })
        
//        print("Token", FIRInstanceID.instanceID().token() ?? <#default value#>)
        
        return true
    }

    func application(_ application: UIApplication,
                     open url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
//        _ = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        if url.absoluteString.startsWith("com.googleusercontent.apps"){
            return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        }
        else {
            return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        }
    }
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        _ = [UIApplicationOpenURLOptionsKey.sourceApplication.rawValue: sourceApplication! as AnyObject,
                                            UIApplicationOpenURLOptionsKey.annotation.rawValue: annotation as AnyObject]
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func scheduleNotification(inSeconds: TimeInterval, completion: @escaping (Bool)->()){
        let attachment = try! UNNotificationAttachment(identifier: "myNoti", url: Bundle.main.url(forResource: "coupon_sample", withExtension: ".jpg")!, options: .none)
        
        let noti = UNMutableNotificationContent()
        noti.title = "Alert!"
        noti.body = "This is a notification"
        
        noti.attachments = [attachment]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: "noti", content: noti, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
            if let error = error{
                print(error.localizedDescription)
                completion(false)
            }
            else{
                completion(true)
            }
        })
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token: String = ""
        for i in 0..<deviceToken.count {
            token += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
        }
        
        print("APN token is: ", token)
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: .unknown)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // Print message ID.
//        if let messageID = userInfo[gcmMessageIDKey] {
//            print("Message ID: \(messageID)")
//        }
        
        // Print full message.
        print(userInfo)
    }
    
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
//                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        // If you are receiving a notification message while your app is in the background,
//        // this callback will not be fired till the user taps on the notification launching the application.
//        // TODO: Handle data of notification
//        
//        // Print message ID.
////        if let messageID = userInfo[gcmMessageIDKey] {
////            print("Message ID: \(messageID)")
////        }
//        
//        // Print full message.
//        print(userInfo)
//        
//        completionHandler(UIBackgroundFetchResult.newData)
//    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        //print("Got notification!")
        
        // Disable coupon for now for testing sake
        //scheduleNotification(inSeconds: 0, completion: { (success) in
        //    print("success", success)
        //})
        
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        
        // Print full message.
        print(userInfo)
        
        // Use timestamp as notification ID
        print(userInfo["timestamp"]!)
        
        controllerManager?.tabbarVC.selectedIndex = 2
        controllerManager?.userVC.pushNotificationView()
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        let authOptions : UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_,_ in })
        
        // For iOS 10 display notification (sent via APNS)
        UNUserNotificationCenter.current().delegate = self
        // For iOS 10 data message (sent via FCM)
        FIRMessaging.messaging().remoteMessageDelegate = self
    
        
        application.registerForRemoteNotifications()
        
        NotificationCenter.default.addObserver(forName: Notification.Name.firInstanceIDTokenRefresh, object: self, queue: nil, using: { (noti) in
            self.tokenRefreshNotification(noti)
        })
        return true
    }
    
    func tokenRefreshNotification(_ notification: Notification) {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
        }
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    
    func connectToFcm() {
        FIRMessaging.messaging().connect { (error) in
            if error != nil {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        
        var bgTask = application.beginBackgroundTask { 
            let ref = FIRDatabase.database().reference().child("TestMessage").observe(.childAdded, with: { (snapshot) in
                self.scheduleNotification(inSeconds: 0, completion: { (success) in
                    print(success)
                })
            })
        }
        
        DispatchQueue.global(qos: .default).async(execute: {() -> Void in
            // Do the work associated with the task, preferably in chunks.
            application.endBackgroundTask(bgTask)
            bgTask = UIBackgroundTaskInvalid
        })
        
//        scheduleNotification(inSeconds: 5, completion: { (success) in
//            if success{
//                print("Success")
//            }
//            else{
//                print("Failure")
//            }
//        })
        
//        let noti = UILocalNotification()
//        noti.alertTitle = "Alert"
//        noti.alertBody = "This is a push notification"
//        noti.fireDate = Date().addingTimeInterval(3)
//        let app = UIApplication.shared
//        app.scheduledLocalNotifications = [noti]
        
//        if #available(iOS 10.0, *) {
//            Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { (timer) in
//                
////                UIApplication.shared.applicationIconBadgeNumber = 135
////                let noti = UILocalNotification()
////                noti.applicationIconBadgeNumber = 123
//            })
//        } else {
//            // Fallback on earlier versions
//        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        UIApplication.shared.cancelAllLocalNotifications()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"])")
        
        // Print full message.
        print("%@", userInfo)
        
        controllerManager?.notificationVC?.loadNotificationsFromDict()
        
        controllerManager?.tabbarVC.selectedIndex = 2
        controllerManager?.userVC.pushNotificationView()
    }
}

extension AppDelegate : FIRMessagingDelegate {
    // Receive data message on iOS 10 devices.
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print("%@", remoteMessage.appData)
        
    }
    
}
