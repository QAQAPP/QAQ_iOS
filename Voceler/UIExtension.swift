//
//  UIExtension.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 6/22/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import BFPaperButton
import MMDrawerController
import LTNavigationBar
import FirebaseAuth

extension UIViewController{
    func initView(){
        touchToHideKeyboard()
        edgesForExtendedLayout = []
    }
    
    func touchToHideKeyboard(){
        let tab = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tab.isEnabled = true
        view.addGestureRecognizer(tab)
    }
    
    func hideKeyboard(){
        view.endEditing(true)
    }
    
    func showMore() {
        drawer.toggle(.left, animated: true, completion: nil)
    }
    
    func setupProfile(){
        if let btn = navigationItem.leftBarButtonItem?.customView as? UIButton{
            btn.addTarget(self, action: #selector(showMore), for: .touchUpInside)
        }
    }
    
    func profileClicked(){
        drawer.toggle(.left, animated: true, completion: nil)
    }
    
    func setProfileItem() {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        btn.addTarget(self, action: #selector(profileClicked), for: .touchUpInside)
        if let img = currUser?.profileImg, img != #imageLiteral(resourceName: "user-50") {
            btn.setImage(img, for: [])
        }
        else{
            btn.setImage(img: #imageLiteral(resourceName: "user-50"), color: .white)
            if let uid = FIRAuth.auth()?.currentUser?.uid{
                NotificationCenter.default.addObserver(self, selector: #selector(setProfileItem), name: NSNotification.Name(uid + "profile"), object: nil)
            }
        }
        btn.board(radius: 20, width: 0, color: .black)
        btn.imageView?.contentMode = .scaleAspectFill
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btn)
    }
}

extension UINavigationBar{
    func setColor(color:UIColor){
        barTintColor = color
        backgroundColor = color
        tintColor = .white
        isTranslucent = true
        titleTextAttributes = [NSFontAttributeName: UIFont(name: "Helvetica Neue", size: 20)!, NSForegroundColorAttributeName: UIColor.white]
        if color == .clear{
            setBackgroundImage(UIImage(), for: .default)
        }
    }
}

extension UIImageView{
    func setup(radius:CGFloat){
        layer.masksToBounds = true
        layer.cornerRadius = radius
    }
    
    func setIcon(img:UIImage, color:UIColor) {
        image = img.withRenderingMode(.alwaysTemplate)
        tintColor = color
    }
}

extension UITextField{
    func setup(radius:CGFloat){
        layer.cornerRadius = radius
    }
}

extension BFPaperButton{
    func setup(radius:CGFloat){
        isRaised = false
        cornerRadius = radius
    }
}

extension UIImage{
    func resize(newWidth: CGFloat) -> UIImage {
        //    let scale = newWidth / image.size.width
        //    let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newWidth))
        draw(in: CGRect(x:0, y:0, width:newWidth, height:newWidth))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

extension UIColor {
    func rgb() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            return (fRed, fGreen, fBlue, fAlpha)
        } else {
            return (0, 0, 0, 0)
        }
    }
}

extension UIView{
    func blury() {
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.backgroundColor = UIColor.clear
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
        } else {
            self.backgroundColor = UIColor.black
        }
    }
    func hideKeyboard(){
        endEditing(true)
    }
    func touchToHideKeyboard(){
        let tab = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tab.isEnabled = true
        addGestureRecognizer(tab)
    }
    func board(radius:CGFloat, width:CGFloat, color:UIColor) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
    func addBorder(edges: UIRectEdge, colour: UIColor = UIColor.white, thickness: CGFloat = 1) -> [UIView] {
        
        var borders = [UIView]()
        
        func border() -> UIView {
            let border = UIView(frame: CGRect.zero)
            border.backgroundColor = colour
            border.translatesAutoresizingMaskIntoConstraints = false
            return border
        }
        
        if edges.contains(.top) || edges.contains(.all) {
            let top = border()
            addSubview(top)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[top(==thickness)]",
                                                               options: [],
                                                               metrics: ["thickness": thickness],
                                                               views: ["top": top]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[top]-(0)-|",
                                                               options: [],
                                                               metrics: nil,
                                                               views: ["top": top]))
            borders.append(top)
        }
        
        if edges.contains(.left) || edges.contains(.all) {
            let left = border()
            addSubview(left)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[left(==thickness)]",
                                                               options: [],
                                                               metrics: ["thickness": thickness],
                                                               views: ["left": left]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[left]-(0)-|",
                                                               options: [],
                                                               metrics: nil,
                                                               views: ["left": left]))
            borders.append(left)
        }
        
        if edges.contains(.right) || edges.contains(.all) {
            let right = border()
            addSubview(right)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:[right(==thickness)]-(0)-|",
                                                               options: [],
                                                               metrics: ["thickness": thickness],
                                                               views: ["right": right]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[right]-(0)-|",
                                                               options: [],
                                                               metrics: nil,
                                                               views: ["right": right]))
            borders.append(right)
        }
        
        if edges.contains(.bottom) || edges.contains(.all) {
            let bottom = border()
            addSubview(bottom)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:[bottom(==thickness)]-(0)-|",
                                                               options: [],
                                                               metrics: ["thickness": thickness],
                                                               views: ["bottom": bottom]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[bottom]-(0)-|",
                                                               options: [],
                                                               metrics: nil,
                                                               views: ["bottom": bottom]))
            borders.append(bottom)
        }
        
        return borders
    }
}

extension UIImage {
    var uncompressedPNGData: NSData! { return UIImagePNGRepresentation(self)! as NSData! }
    var highestQualityJPEGNSData: NSData! { return UIImageJPEGRepresentation(self, 1.0)! as NSData! }
    var highQualityJPEGNSData: NSData! { return UIImageJPEGRepresentation(self, 0.75)! as NSData! }
    var mediumQualityJPEGNSData: NSData! { return UIImageJPEGRepresentation(self, 0.5)! as NSData! }
    var lowQualityJPEGNSData: NSData! { return UIImageJPEGRepresentation(self, 0.25)! as NSData! }
    var lowestQualityJPEGNSData:NSData! { return UIImageJPEGRepresentation(self, 0.0)! as NSData! }
    func dataAtMost(bytes:Int)->Data{
        if uncompressedPNGData.length <= bytes{
            return uncompressedPNGData as Data
        }
        else if highestQualityJPEGNSData.length <= bytes{
            return highestQualityJPEGNSData as Data
        }
        else if mediumQualityJPEGNSData.length <= bytes{
            return mediumQualityJPEGNSData as Data
        }
        else if lowQualityJPEGNSData.length <= bytes{
            return lowQualityJPEGNSData as Data
        }
        else{
            return lowestQualityJPEGNSData as Data
        }
    }
}

extension UIButton{
    func setImage(img:UIImage, color:UIColor){
        let img = img.withRenderingMode(.alwaysTemplate)
        tintColor = color
        setImage(img, for: [])
    }
}

public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
}
