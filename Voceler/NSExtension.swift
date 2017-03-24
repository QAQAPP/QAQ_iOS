//
//  NSExtension.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 6/22/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import Foundation
import NSString_Email
import SCLAlertView

extension String{
    func isEmail() -> Bool{
        return (self as NSString).isEmail()
    }
}

extension NSError{
    func show(){
        _ = SCLAlertView().showError("Error", subTitle: localizedDescription)
    }
}

public extension Notification.Name{
    static let ScratchComplete = Notification.Name("ScratchComplete")
    static let QuestionLoaded = Notification.Name("QuestionLoaded")
    static let TagsLoaded = Notification.Name("TagsLoaded")
    static let TagsSearched = Notification.Name("TagsSearched")
}
