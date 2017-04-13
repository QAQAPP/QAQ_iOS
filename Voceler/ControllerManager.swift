//
//  ControllerManager.swift
//  QAQ
//
//  Created by 钟镇阳 on 10/21/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import SCLAlertView

class ControllerManager: NSObject, UITabBarControllerDelegate, UIPopoverPresentationControllerDelegate, AskProblemVCDelegate, TagsControllerDelegate{
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
	var dummyAskProblemVC = DummyTestVC()
	var overlay:UIView!
    var askProblemVC:AskProblemVC{
        let board = UIStoryboard(name: "Main", bundle: nil)
        let vc = board.instantiateViewController(withIdentifier: "Ask Question") as! AskProblemVC
		vc.delegate = self
        return vc
    }
    var tagsVC:TagsController{
        let board = UIStoryboard(name: "Main", bundle: nil)
        let vc = board.instantiateViewController(withIdentifier: "AddTags") as! TagsController
		vc.delegate = self
        return vc
    }
    
    func getUserVC(user:UserModel)->UserVC{
        let vc = UserVC(nibName: "UserVC", bundle: nil)
        vc.thisUser = user
        return vc
    }
    
//    func profileVC(user:UserModel)->ProfileVC{
//        let vc = ProfileVC(nibName: "ProfileVC", bundle: nil)
//        vc.edgesForExtendedLayout = .top
//        vc.thisUser = user
//        return vc
//    }
    
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
//        collectionVC?.loadCollections()
//        collectionNav = UINavigationController(rootViewController: collectionVC)
//        collectionNav.navigationBar.setColor(color: themeColor)
//        let collectionItem = UITabBarItem()
//        collectionItem.image = #imageLiteral(resourceName: "book_shelf-25")
//        collectionNav.tabBarItem = collectionItem
        notificationVC = NotificationVC()
    
        let askItem = UITabBarItem()
        askItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
        askItem.image = #imageLiteral(resourceName: "Oval 1").withRenderingMode(.alwaysOriginal)
        let askVC = askProblemVC
//		let askVC = dummyAskProblemVC
        askVC.tabBarItem = askItem
        
        settingsVC = SettingsVC()
//        settingsNav = UINavigationController(rootViewController: settingsVC)
//        settingsNav.navigationBar.setColor(color: themeColor)
        
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
	
	// MARK:UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is AskProblemVC{
//		if viewController is DummyTestVC{
            if gameManager!.checkAskQuestion(){
//                let nav = UINavigationController(rootViewController: dummyAskProblemVC)
				let nav = UINavigationController(rootViewController: askProblemVC)
                nav.navigationBar.setColor(color: themeColor)
				nav.modalPresentationStyle = UIModalPresentationStyle.popover;
				nav.view.backgroundColor = UIColor.clear
				nav.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: 400)
				nav.setNavigationBarHidden(true, animated: false)
				let popover:UIPopoverPresentationController = nav.popoverPresentationController!;
				let view = tabBarController.tabBar.selectedItem?.value(forKey: "view") as! UIView?
				popover.sourceView = tabBarController.tabBar
				popover.sourceRect = (view?.frame)!
				popover.delegate = self
                tabBarController.show(nav, sender: tabBarController)
            }
            return false
        }
        return true
    }
	
	// MARK:UIPopoverPresentationControllerDelegates
	func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
		return UIModalPresentationStyle.none
	}
	
	func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
		let parentView = tabbarVC.selectedViewController?.view
		
		let overlay = UIView(frame: (parentView?.bounds)!)
		overlay.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
		parentView?.addSubview(overlay)
		self.overlay = overlay
		tabbarVC.selectedViewController?.view.addSubview(overlay)
	}
	
	func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
		overlay.removeFromSuperview()
	}
	
	// MARK:AskProblemVCDelegate
	func dismisOverlay() {
		overlay.removeFromSuperview()
	}
	
	// MARK:TagsControllerDelegate
	func dismisTagsOverlay() {
		overlay.removeFromSuperview()
	}

}
