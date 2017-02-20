//
//  ControllerManager.swift
//  QAQ
//
//  Created by 钟镇阳 on 10/21/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import SCLAlertView

class ControllerManager: NSObject, UITabBarControllerDelegate{
    var mainVC:MainVC!
    var collectionVC:CollectionVC!
    var notificationVC:NotificationVC!
    var settingsVC:SettingsVC!
    var userVC:UserVC!
    var mainNav:UINavigationController!
    var collectionNav:UINavigationController!
    
    var userNav:UINavigationController!
//    var settingsNav:UINavigationController!
    
    var tabbarVC = UITabBarController()
    var askProblemVC:AskProblemVC{
        let board = UIStoryboard(name: "Main", bundle: nil)
        let vc = board.instantiateViewController(withIdentifier: "Ask Question") as! AskProblemVC
        return vc
    }
    var tagsVC:TagsController{
        let board = UIStoryboard(name: "Main", bundle: nil)
        let vc = board.instantiateViewController(withIdentifier: "AddTags") as! TagsController
        return vc
    }
    
    func profileVC(user:UserModel)->ProfileVC{
        let vc = ProfileVC(nibName: "ProfileVC", bundle: nil)
        vc.edgesForExtendedLayout = .top
        vc.thisUser = user
        return vc
    }
    
    override init() {
        super.init()
        mainVC = MainVC()
        mainVC.edgesForExtendedLayout = []
        mainNav = UINavigationController(rootViewController: mainVC)
        mainNav.navigationBar.setColor(color: themeColor)
        let mainItem = UITabBarItem()
        mainItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
        mainItem.selectedImage = #imageLiteral(resourceName: "Oval 2").withRenderingMode(.alwaysOriginal)
        mainItem.image = #imageLiteral(resourceName: "Home - simple-line-icons").withRenderingMode(.alwaysOriginal)
        mainNav.tabBarItem = mainItem
        
        collectionVC = CollectionVC()
//        collectionNav = UINavigationController(rootViewController: collectionVC)
//        collectionNav.navigationBar.setColor(color: themeColor)
//        let collectionItem = UITabBarItem()
//        collectionItem.image = #imageLiteral(resourceName: "book_shelf-25")
//        collectionNav.tabBarItem = collectionItem
        
        let askItem = UITabBarItem()
        askItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
        askItem.image = #imageLiteral(resourceName: "Oval 1").withRenderingMode(.alwaysOriginal)
        let askVC = askProblemVC
        askVC.tabBarItem = askItem
        
        settingsVC = SettingsVC()
//        settingsNav = UINavigationController(rootViewController: settingsVC)
//        settingsNav.navigationBar.setColor(color: themeColor)
        
        notificationVC = NotificationVC()
        
        userVC = UserVC(nibName: "UserVC", bundle: nil)
        userVC.thisUser = currUser
        userNav = UINavigationController(rootViewController: userVC)
        let userItem = UITabBarItem()
        userItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
        userItem.image = #imageLiteral(resourceName: "User - simple-line-icons").withRenderingMode(.alwaysOriginal)
        userItem.selectedImage = #imageLiteral(resourceName: "User selected").withRenderingMode(.alwaysOriginal)
        userNav.tabBarItem = userItem
        
        tabbarVC.setViewControllers([mainNav, askVC, userNav], animated: true)
        tabbarVC.delegate = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is AskProblemVC{
            if currUser!.qInProgress.count >= currUser!.qInProgressLimit!{
                _ = SCLAlertView().showError("Sorry", subTitle: "You are only allowed to have up to \(currUser!.qInProgressLimit) in progress questions. Please conclude a question.")
            }
            else{
                let nav = UINavigationController(rootViewController: askProblemVC)
                nav.navigationBar.setColor(color: themeColor)
                tabBarController.show(nav, sender: tabBarController)
            }
            return false
        }
        return true
    }
}
