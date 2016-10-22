//
//  ControllerManager.swift
//  QAQ
//
//  Created by 钟镇阳 on 10/21/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit

class ControllerManager: NSObject {
    var mainVC:MainVC!
    var collectionVC:CollectionVC!
    var settingsVC:SettingsVC!
    var profileVC:ProfileVC!
    var mainNav:UINavigationController!
    var collectionNav:UINavigationController!
    var profileNav:UINavigationController!
    var settingsNav:UINavigationController!
    let tabbarVC = UITabBarController()
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
        
        settingsVC = SettingsVC()
        settingsVC.edgesForExtendedLayout = []
        settingsNav = UINavigationController(rootViewController: settingsVC)
        settingsNav.navigationBar.setColor(color: themeColor)
        let settingsItem = UITabBarItem()
        settingsItem.image = #imageLiteral(resourceName: "settings-25")
        settingsNav.tabBarItem = settingsItem
        
        profileVC = ProfileVC(nibName: "ProfileVC", bundle: nil)
        profileVC.edgesForExtendedLayout = []
        profileVC.thisUser = currUser
        profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.navigationBar.setColor(color: themeColor)
        let profileItem = UITabBarItem()
        profileItem.image = #imageLiteral(resourceName: "gender_neutral_user-25")
        profileNav.tabBarItem = profileItem
        
        tabbarVC.setViewControllers([mainNav, collectionNav, profileNav, settingsNav], animated: true)
    }
}
