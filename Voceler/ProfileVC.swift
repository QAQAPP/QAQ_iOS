//
//  ProfileVC.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 6/27/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import DBProfileViewController
import SDAutoLayout
import TextFieldEffects
import BFPaperButton
import FirebaseAuth
import UIViewController_NavigationBar
import SCLAlertView
import SwiftSpinner
import FirebaseStorage

class ProfileVC: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // UIVars
    @IBOutlet weak var wallTop: NSLayoutConstraint!
    @IBOutlet weak var wallImg: UIImageView!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameTF: UITextField?{
        didSet{
            if let username = thisUser?.username{
                usernameTF!.text = username
            }
            else{
                usernameTF!.text = ""
            }
        }
    }
    @IBOutlet weak var controlView: UIView?
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var table: UITableView?
    @IBOutlet weak var moneyImg: UIImageView!
    @IBOutlet weak var scrollHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomSpace: NSLayoutConstraint?
    var editBtn = BFPaperButton(raised: false)!
    private var takeProfile = UIImageView(image: #imageLiteral(resourceName: "compact_camera-50"))
    private var takeWall = UIImageView(image: #imageLiteral(resourceName: "compact_camera-50"))
    private var setImgTo = "profileImg"
    private var picker = UIImagePickerController()
    var thisUser:UserModel?{
        didSet{
            loadUserInfo()
        }
    }
    let old_val = NSMutableArray()
    
    // FieldVars
    let attributeArr = ["What's up", "Region", "Sex", "Birthday", "Profession"]
    var contentArr:[NSMutableString] = ["I'll regrade your ass ignment!", "Los Angeles", "Male", "10-06-1995"]
    var editable = true
    private var loadNeeded = 3
    
    // Actions
    private var editMode = false
    func editAction() {
        if loadNeeded > 0 {
            _ = SCLAlertView().showWait("Sorry", subTitle: "Synchronizing user info...", duration: 1)
            return
        }
        editMode = !editMode
        table!.allowsSelection = editMode
        usernameTF!.isEnabled = editMode
        takeProfile.isHidden = !editMode
        takeWall.isHidden = !editMode
        table!.reloadData()
        if editMode{
            editBtn.setTitle("  Done", for: [])
            old_val.removeAllObjects()
            for item in contentArr {
                old_val.add(item as String)
            }
            old_val.add(profileImg.image!)
            old_val.add(wallImg.image!)
            old_val.add(usernameTF!.text!)
            usernameTF!.layer.borderWidth = 1
        }
        else {
            editBtn.setTitle("  Edit", for: [])
            usernameTF?.layer.borderWidth = 0
            for i in 0..<contentArr.count {
                if old_val[i] as! NSString != contentArr[i] {
                    showSaveAlert()
                    return
                }
            }
            if old_val[contentArr.count] as? UIImage != profileImg.image || old_val[contentArr.count+1] as? UIImage != wallImg.image || old_val[contentArr.count+2] as? String != usernameTF?.text{
                showSaveAlert()
            }
        }
    }
    
    func cellTapped(textField:UITextField, text:NSMutableString){
        if editMode{
            switch textField.placeholder! {
            case "Sex":
                if text == "Male"{
                    text.setString("Female")
                    textField.text = "Female"
                }
                else {
                    text.setString("Male")
                    textField.text = "Male"
                }
            case "Birthday":
                let vc = VC(name: "Birthday", isNav: false, isCenter: false) as! Birthday
                vc.text = text
                vc.textField = textField
                navigationController?.pushViewController(vc, animated: true)
            default:
                textField.isUserInteractionEnabled = true
                textField.becomeFirstResponder()
            }
        }
    }
    
    func changeImg(target:UITapGestureRecognizer) {
        if editMode{
            if profileImg.gestureRecognizers!.contains(target){
                setImgTo = "profileImg"
            }
            else{
                setImgTo = "wallImg"
            }
            show(picker, sender: self)
        }
    }
    
    // Functions
    private func showSaveAlert(){
        let alert = SCLAlertView()
        _ = alert.addButton("Save", action: {
            NotificationCenter.default.post(name: NSNotification.Name("UsernameLoaded"), object: self.usernameTF?.text)
            for i in 0..<self.contentArr.count{
                if self.old_val[i] as! String != self.contentArr[i] as String{
                    self.old_val[i] = self.contentArr[i] as String
                    self.thisUser?.ref.child(self.attributeArr[i]).setValue(self.old_val[i])
                }
            }
            if self.old_val[self.contentArr.count] as! UIImage != self.profileImg.image!{
                self.old_val[self.contentArr.count] = self.profileImg.image!
                _ = SwiftSpinner.show("Uploading profile image...")
                currUser?.profileImg = self.profileImg.image
                self.thisUser?.storageRef.child("profileImg.jpeg").put(self.profileImg.image!.dataAtMost(bytes: 100*1024))
                memoryHandler.imageStorage[self.thisUser!.uid + "profile"] = self.profileImg.image
                NotificationCenter.default.post(name: NSNotification.Name(self.thisUser!.uid + "profile"), object: nil)
                self.setProfileItem()
                SwiftSpinner.hide()
            }
            if self.old_val[self.contentArr.count+1] as! UIImage != self.wallImg.image!{
                self.old_val[self.contentArr.count+1] = self.wallImg.image!
                _ = SwiftSpinner.show("Uploading wall image...")
                currUser?.wallImg = self.wallImg.image
                self.thisUser?.storageRef.child("wallImg.jpeg").put(self.wallImg.image!.dataAtMost(bytes: 400*1024))
                memoryHandler.imageStorage[self.thisUser!.uid + "wall"] = self.wallImg.image
                SwiftSpinner.hide()
            }
            self.old_val[self.contentArr.count+1] = self.wallImg.image!
            if self.old_val[self.contentArr.count+2] as? String != self.usernameTF?.text!{
                self.old_val[self.contentArr.count+2] = self.usernameTF!.text!
                self.thisUser?.ref.child("username").setValue(self.usernameTF!.text!)
            }
        })
        let resp = alert.showNotice("Save", subTitle: "Do you want to save changes?", closeButtonTitle: "Cancel", duration: 0, colorStyle: 0x2866BF, colorTextButton: 0xFFFFFF, circleIconImage: nil, animationStyle: SCLAnimationStyle.bottomToTop)
        resp.setDismissBlock { 
            for i in 0..<self.contentArr.count{
                self.contentArr[i] = NSMutableString(string: self.old_val[i] as! NSString)
            }
            self.profileImg.image = self.old_val[self.contentArr.count] as? UIImage
            self.wallImg.image = self.old_val[self.contentArr.count+1] as? UIImage
            self.usernameTF!.text = self.old_val[self.contentArr.count+2] as? String
            self.table!.reloadData()
        }
    }
    
    private func setEditable(){
        editable = FIRAuth.auth()?.currentUser?.uid == thisUser?.uid
        controlView?.isHidden = !editable
        bottomSpace?.constant = editable ? 50 : 0
    }
    
    func setupUI(){
        navigationBar.setColor(color: .clear)
        picker.delegate = self
        edgesForExtendedLayout = .top
        title = ""
        usernameTF!.placeholder = "Username"
        usernameTF!.layer.borderColor = UIColor.lightGray.cgColor
        contentView.touchToHideKeyboard()
        scroll.delegate = self
        view.backgroundColor = lightGray
        controlView!.backgroundColor = themeColor
        profileImg.board(radius: 50, width: 5, color: .lightGray)
        _ = profileImg.sd_layout().topSpaceToView(wallImg, -70)?.heightIs(100)?.widthIs(100)
        table!.delegate = self
        table!.dataSource = self
        table!.register(UINib(nibName: "ProfileCell", bundle: nil), forCellReuseIdentifier: "ProfileCell")
        table!.allowsSelection = false
        moneyImg.setIcon(img: #imageLiteral(resourceName: "money"), color: pinkColor)
        
        editBtn.backgroundColor = themeColor
        editBtn.tintColor = .white
        editBtn.setTitle("  Edit", for: [])
        editBtn.setImage(#imageLiteral(resourceName: "edit_row-32").withRenderingMode(.alwaysTemplate), for: [])
        controlView!.addSubview(editBtn)
        editBtn.addTarget(self, action: #selector(editAction), for: [.touchUpInside])
        _ = editBtn.sd_layout()
            .topSpaceToView(controlView, 0)?
            .bottomSpaceToView(controlView, 0)?
            .leftSpaceToView(controlView, 0)?
            .rightSpaceToView(controlView, 0)
        resizeTableView()
        
        contentView.addSubview(takeProfile)
        _ = takeProfile.sd_layout()
            .topSpaceToView(profileImg, -36)?
            .leftSpaceToView(profileImg, -36)?
            .heightIs(36)?
            .widthIs(36)
        
        wallImg.addSubview(takeWall)
        _ = takeWall.sd_layout()
            .bottomSpaceToView(wallImg, 0)?
            .rightSpaceToView(wallImg, 10)?
            .heightIs(36)?
            .widthIs(36)
        
        takeProfile.isHidden = true
        takeWall.isHidden = true
        takeProfile.setIcon(img: #imageLiteral(resourceName: "compact_camera-50"), color: .gray)
        takeWall.setIcon(img: #imageLiteral(resourceName: "compact_camera-50"), color: .gray)
        
        let profileTap = UITapGestureRecognizer(target: self, action: #selector(changeImg(target:)))
        profileImg.addGestureRecognizer(profileTap)
        let wallTap = UITapGestureRecognizer(target: self, action: #selector(changeImg(target:)))
        wallImg.addGestureRecognizer(wallTap)
        
        setProfileImg()
        setWallImg()
    }
    
    func resizeTableView() {
        table!.reloadData()
        scrollHeight!.constant = UIScreen.main.bounds.width * 0.4 + 110 + table!.contentSize.height
    }
    
    func setProfileImg(){
        if thisUser?.profileImg != nil {
            profileImg.image = thisUser?.profileImg
            loadComplete()
        }
        else{
            NotificationCenter.default.addObserver(self, selector: #selector(setProfileImg), name: NSNotification.Name(self.thisUser!.uid + "profile"), object: nil)
        }
    }
    
    func setWallImg(){
        wallImg.contentMode = .scaleAspectFill
        if thisUser?.wallImg != nil {
            wallImg.image = thisUser?.wallImg
            loadComplete()
        }
        else{
            NotificationCenter.default.addObserver(self, selector: #selector(setWallImg), name: NSNotification.Name(self.thisUser!.uid + "wall"), object: nil)
        }
    }

    func loadUserInfo(){
        if let username = thisUser?.username{
            usernameTF?.text = username
        }
        else{
            usernameTF?.text = ""
        }
        contentArr.removeAll()
        for item in attributeArr {
            if let val = thisUser?.infoDic[item]{
                contentArr.append(NSMutableString(string: val))
            }
            else{
                contentArr.append(NSMutableString())
            }
        }
        table?.reloadData()
        loadComplete()
    }
    
    private func loadComplete(){
        loadNeeded -= 1
    }
    
    // Override functions
    override func viewWillAppear(_ animated: Bool) {
        setEditable()
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfile()
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attributeArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell") as! ProfileCell
        cell.setVC(vc: self)
        cell.textField.placeholder = attributeArr[indexPath.row]
        cell.textValue = contentArr[indexPath.row]
        cell.setEdit(editMode: editMode)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true) {
            if self.setImgTo == "profileImg"{
                self.profileImg.image = info[UIImagePickerControllerOriginalImage] as? UIImage
            }
            else if self.setImgTo == "wallImg"{
                self.wallImg.image = info[UIImagePickerControllerOriginalImage] as? UIImage
            }
        }
    }
    
    func keyboardWasShown(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.bottomSpace?.constant = keyboardFrame.size.height + 20
        })
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hideKeyboard()
    }
    
    override func hasCustomNavigationBar() -> Bool {
        return true
    }
}
