//
//  AppDelegate.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 6/21/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManager
import Networking
import GoogleSignIn
import SDAutoLayout
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        // Override point for customization after application launch.
        FIRApp.configure()
        IQKeyboardManager.shared().isEnabled = true
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

//        _ = questionManager.getQuestion()
//        let networking = Networking(baseURL: "http://45.55.110.230:3000/v1")
//        networking.authenticate(headerKey: "uid", headerValue: "6Z6TrOaxPkWG9OaInB0x3k6mir73")
//        networking.authenticate(headerKey: "token", headerValue: "3AE5BCA817F76866F6A5A6181458AB73B8CC538FC0C4C092A8D678D72AD404B6B58D7F7BBB1CA7FB5BF2E91E888EECC5DBDBCD968E762F5C932C82AB30D85141481979861AFE3E66D5498FDA524BE8FD52FD054CFC87C54B17995BD7011FDAB9C35A35560045B1E4D618488E47C44C263587959E724E85CE5A7AF1DD0C8ADAD6FE31D37187D2312D1B3EFD3FF2876E25005E44EA88A879E9999B6D61988607F7345D414CF5FD4A0878535BBD478B2DBB068DCF69BBFDE7A76DDB47BEB43546935AA2AEED194575068FFC128462F610FA04837F4D56A470B65005E964BDA372B96C01D0A7FE8AE841EB8091E55E0B192588FC2B7B6E23DD85B7DFDE652DDAF14028D80C61D5D865B83976A5B92F6ABC3C02692218EA7F9FC1D8729C3CAB58DCF375EBD31C06920C20D8AF95570B704BB2D3F6B6AFE9046D556D0149EECB4A5730C231F52BD4BA53C378C958A720709372440AB822315184F4452E2D3864103718B3AAB7A96E4EAAC09CC20CD3D8C841C76C233436B954B082AA2060F8B7D0B63C1B3702D5F9A8449F9692292F44B71B0A32417083E892C349D958D6303D44DF63DDB51F85B87741C144C9739E2A421DA297F9A94F2E1CC2C8875119503B894196295A1C0B462ACBA52A2DFF33DD0D36A5F37B1738B71CD1291F17C69321A5BF257E44A3F75762838FF761498A3D27E636AC56B34F4B38C804E4FD2FE36D20C3D193966A656639DD55214E4022EACA9BA8736AB7B5EECFEC75B10BCB501B44440BB5772A823D02DA42ED5006C0EC89F0D89D58BE294D1431D248568EDCF45A65F7EA21061CAB1AF7D41503B3F937C9C04A1617E26A803712B32E04EE43E70CB17F00FB9316BA2859E0E7D028CFF45678C8F17FB31FA0400A602C28A2FC3AA46EA13D7B70292CFB5C3F7E09ECF33B1D60038262288C848C0E55CBFE7249E7E59C5C5F6E8123A9C55ED35EA05F1C61BFBE7572679D68017DE346E7566A2F86063B1E0DB415721606361F15FA47D5ADEFA3CE1F182C97D481D0046A2B2305EB62CBAD9EFC47AC6991D34EA74A3E0DAE940B0A522FE94F0B8A70DECA977F9B7FF94BB1DEAFFAF389C69EF7E2FF601051A9B8A5D1B7697986A154A1C2F642A69BD241EC9E7A1B4B35B71DCDE9FC8C5E0327D3264E808B9D8D1F00257BFD497702E07425A09DC0B9CDBF7D91AF2DB854BB189EFFCF3B9AD8B36AB0A2E74F622CD88EA4B80FD50706A3D57D3A5AE03F6F4B050D2B47E789C40E9FE0D8F0B2170A94FD1A87595B06B4BFD6FBFA0B7343E828332A4580E3ED93D4A782E8")
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
        
        return true
    }

    func application(_ application: UIApplication,
                     open url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
//        _ = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        print(url)
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

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

