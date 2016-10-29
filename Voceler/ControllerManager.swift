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
    var settingsVC:SettingsVC!
    var profileVC:ProfileVC!
    var mainNav:UINavigationController!
    var collectionNav:UINavigationController!
    var profileNav:UINavigationController!
    var settingsNav:UINavigationController!
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
        mainItem.image = #imageLiteral(resourceName: "question_mark-25")
        mainNav.tabBarItem = mainItem
        
        collectionVC = CollectionVC(nibName: "CollectionVC", bundle: nil)
        collectionVC.edgesForExtendedLayout = []
        collectionNav = UINavigationController(rootViewController: collectionVC)
        collectionNav.navigationBar.setColor(color: themeColor)
        let collectionItem = UITabBarItem()
        collectionItem.image = #imageLiteral(resourceName: "book_shelf-25")
        collectionNav.tabBarItem = collectionItem
        
        let askItem = UITabBarItem()
        askItem.image = #imageLiteral(resourceName: "ask_question-25")
        let askVC = askProblemVC
        askVC.tabBarItem = askItem
        
        settingsVC = SettingsVC()
        settingsVC.edgesForExtendedLayout = []
        settingsNav = UINavigationController(rootViewController: settingsVC)
        settingsNav.navigationBar.setColor(color: themeColor)
        let settingsItem = UITabBarItem()
        settingsItem.image = #imageLiteral(resourceName: "settings-25")
        settingsNav.tabBarItem = settingsItem
        
        profileVC = ProfileVC(nibName: "ProfileVC", bundle: nil)
        profileVC.edgesForExtendedLayout = .top
        profileVC.thisUser = currUser
        profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.navigationBar.setColor(color: themeColor)
        let profileItem = UITabBarItem()
        profileItem.image = #imageLiteral(resourceName: "gender_neutral_user-25")
        profileNav.tabBarItem = profileItem
        
        tabbarVC.setViewControllers([mainNav, collectionNav, askVC, profileNav, settingsNav], animated: true)
        tabbarVC.delegate = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is AskProblemVC{
            if currUser!.qInProgress.count >= currUser!.qInProgressLimit{
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
