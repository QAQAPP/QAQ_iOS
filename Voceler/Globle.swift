//
//  Globle.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 6/25/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import MMDrawerController

let themeColor = UIColor(red: 0.965, green: 0.447, blue: 0.329, alpha: 1)
let buttomColor = UIColor(red: 0.694986, green: 0.813917, blue: 0.213036, alpha: 1)
let pinkColor = UIColor(red: 1, green: 0.3, blue: 0.3, alpha: 1.0)
let darkRed = UIColor(red: 0.8824, green: 0.0039, blue: 0.2353, alpha: 1.0)
let lightGray = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
let btnBGColor = UIColor(red: 0.941, green: 0.98, blue: 1, alpha: 1)
var currUser:UserModel?{
    didSet{
        currUser?.loadCollection()
    }
}
var appSetting = SettingModel()
var questionManager:QuestionManager!
var memoryHandler = MemoryHandler()
var controllerManager:ControllerManager!

func getVC(name:String) -> UIViewController {
    let board = UIStoryboard(name: "Main", bundle: nil)
    let vc = board.instantiateViewController(withIdentifier: name)
    vc.edgesForExtendedLayout = []
    return vc
}

func getNav(name:String, isCenter:Bool) -> UINavigationController {
    let vc = getVC(name: name)
    let nav = UINavigationController(rootViewController: vc)
    nav.navigationBar.barStyle = .blackTranslucent
    vc.title = name
    if isCenter{
        vc.setProfileItem()
    }
    nav.navigationBar.setColor(color: themeColor)
    return nav
}

//internal var drawerVC:MMDrawerController?
//var drawer:MMDrawerController{
//    if let vc = drawerVC{
//        return vc
//    }
//    else {
//        let left = getVC(name: "CtrlVC")
//        let vc = MMDrawerController(center: VC(name: "Question"), leftDrawerViewController: left)!
//        vc.openDrawerGestureModeMask = .panningCenterView
//        vc.closeDrawerGestureModeMask = .panningCenterView
//        drawerVC = vc
//        vc.closeDrawerGestureModeMask = .all
//        return vc
//    }
//}

//internal var myVC = [String:UIViewController]()

//func clearVC(){
//    myVC.removeAll()
//    drawerVC = nil
//    currUser = nil
//}

//func VC(name:String, isNav:Bool = true, isCenter:Bool = true, isNew:Bool = false) -> UIViewController{
//    if isNew{
//        return getVC(name: name)
//    }
//    else if let vc = myVC[name]{
//        return vc
//    }
//    else if name == "CollectionQuestion"{
//        let board = UIStoryboard(name: "Main", bundle: nil)
//        let vc = board.instantiateViewController(withIdentifier: "Question") as! QuestionVC
//        vc.title = "Question"
//        vc.edgesForExtendedLayout = []
//        myVC[name] = vc
//        return vc
//    }
//    else if isNav{
//        myVC[name] = getNav(name: name, isCenter: isCenter)
//        return myVC[name]!
//    }
//    else {
//        myVC[name] = getVC(name: name)
//        return myVC[name]!
//    }
//}

func randFloat()->CGFloat{
    return CGFloat(Float(arc4random()) / Float(UINT32_MAX))/2 + 0.5
}

func getRandomColorImage()->UIImage{
    return getImageWithColor(color: getRandomColor(), size: CGSize(width: 100, height: 100))
}

func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
    let rect = CGRect(x:0, y:0, width:size.width, height:size.height)
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    color.setFill()
    UIRectFill(rect)
    let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return image
}

func getRandomColor()->UIColor{
    return UIColor(red: randFloat(), green: randFloat(), blue: randFloat(), alpha: 1)
}

func changingColor(firstColor:UIColor, secondeColor:UIColor, fraction:CGFloat) -> CGColor {
    let (red1, green1, blue1, alpha1) = firstColor.rgb()
    let (red2, green2, blue2, alpha2) = secondeColor.rgb()
    let red = red2 * fraction + red1 * (1 - fraction)
    let green = green2 * fraction + green1 * (1 - fraction)
    let blue = blue2 * fraction + blue1 * (1 - fraction)
    let alpha = alpha2 * fraction + alpha1 * (1 - fraction)
    return UIColor(red: red, green: green, blue: blue, alpha: alpha).cgColor
}

func color(hex: Int) -> UIColor {
    let red = CGFloat(hex >> 16 & 0xff) / 255
    let green = CGFloat(hex >> 8 & 0xff) / 255
    let blue  = CGFloat(hex & 0xff) / 255
    return UIColor(red: red, green: green, blue: blue, alpha: 1)
}

func imageRotatedByDegrees(oldImage: UIImage, deg degrees: CGFloat) -> UIImage {
    //Calculate the size of the rotated view's containing box for our drawing space
    let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: oldImage.size.width, height: oldImage.size.height))
    let t: CGAffineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat(M_PI / 180))
    rotatedViewBox.transform = t
    let rotatedSize: CGSize = rotatedViewBox.frame.size
    //Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize)
    let bitmap: CGContext = UIGraphicsGetCurrentContext()!
    //Move the origin to the middle of the image so we will rotate and scale around the center.
    bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
    //Rotate the image context
    bitmap.rotate(by: (degrees * CGFloat(M_PI / 180)))
    //Now, draw the rotated/scaled image into the context
    bitmap.scaleBy(x: 1.0, y: -1.0)
    bitmap.draw(oldImage.cgImage!, in: CGRect(x: -oldImage.size.width / 2, y: -oldImage.size.height / 2, width: oldImage.size.width, height: oldImage.size.height))
    let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return newImage
}
