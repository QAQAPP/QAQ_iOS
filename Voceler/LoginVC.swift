//
//  ViewController.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 6/21/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

// UIVars

// FieldVars

// Actions

// Functions

// Override functions

import UIKit
import TextFieldEffects
import BFPaperButton
import SwiftString3
import SCLAlertView
import FirebaseAuth
import SwiftSpinner
import FirebaseDatabase
import GoogleSignIn
import Firebase
import FBSDKLoginKit


class LoginVC: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate, FBSDKLoginButtonDelegate{
    // UIVars
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginBtn: BFPaperButton!
    @IBOutlet weak var signupBtn: BFPaperButton!
    @IBOutlet weak var resetBtn: BFPaperButton!
    @IBOutlet weak var googleLoginBtn: UIButton!
    @IBOutlet weak var facebookLoginBtn: FBSDKLoginButton!
    
    // FieldVars
    var repassField: UITextField?
    
    // Actions
    @IBAction func fbLoginAct(_ sender: AnyObject) {
        
    }
    
    @IBAction func gLoginAct(_ sender: AnyObject) {
        let spinner = SwiftSpinner.show("Login...")
        spinner.backgroundColor = themeColor
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func loginAct(_ sender: AnyObject) {
        if checkEmail(showAlert: true) && checkPassword(showAlert: true){
            let spinner = SwiftSpinner.show("Login...")
            spinner.backgroundColor = themeColor
            FIRAuth.auth()?.signIn(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
                DispatchQueue.main.async(execute: {
                    SwiftSpinner.hide()
                    if let error = error{
                        _ = SCLAlertView().showError("Sorry", subTitle: error.localizedDescription)
                    }
                    else if let user = user{
                        let standard = UserDefaults.standard
                        standard.set(self.emailField.text!, forKey: "username")
                        standard.set(self.passwordField.text!, forKey: "password")
                        self.login(user: user)
                    }
                    else {
                        _ = SCLAlertView().showError("Sorry", subTitle: "Unable to find the user.")
                    }
                })
            })
        }
    }
    
    @IBAction func signupAct(_ sender: AnyObject) {
        if checkEmail(showAlert: true) && checkPassword(showAlert: true){
            showConfirmPsw()
        }
    }
    
    @IBAction func resetAct(_ sender: AnyObject) {
        if let text = emailField.text , text.isEmail(){
            let spinner = SwiftSpinner.show("Processing...")
            spinner.backgroundColor = themeColor
            FIRAuth.auth()?.sendPasswordReset(withEmail: text, completion: { (error) in
                SwiftSpinner.hide()
                DispatchQueue.main.async(execute: {
                    if let error = error{
                        _ = SCLAlertView().showError("Sorry", subTitle: error.localizedDescription)
                    }
                    else {
                        _ = SCLAlertView().showSuccess("Success", subTitle: "An Email to reset password has been sent to you.")
                    }
                })
            })
        }
        else {
            _ = SCLAlertView().showError("Sorry", subTitle: "Incorrect Email format.")
        }
    }
    
    // Functions
    func initUI(){
        emailField.setup(radius: 5)
        passwordField.setup(radius: 5)
        loginBtn.setup(radius: 5)
        signupBtn.setup(radius: 5)
        resetBtn.setup(radius: 5)
        loginBtn.backgroundColor = btnBGColor
        signupBtn.backgroundColor = btnBGColor
        loginBtn.setTitleColor(themeColor, for: [])
        signupBtn.setTitleColor(themeColor, for: [])
        
        facebookLoginBtn.delegate = self
        facebookLoginBtn.readPermissions = ["public_profile", "email"]
    }
    
    func initNoti(){
        let notiCenter = NotificationCenter.default
        notiCenter.addObserver(self, selector: #selector(emailChange(noti:)), name: Notification.Name.UITextFieldTextDidChange, object: emailField)
        notiCenter.addObserver(self, selector: #selector(passwordChange(noti:)), name: Notification.Name.UITextFieldTextDidChange, object: passwordField)
    }
    
    func emailChange(noti:Notification) {
        if checkEmail(){
            emailField.textColor = UIColor.black
        }
        else {
            emailField.textColor = UIColor.red
        }
    }
    
    func passwordChange(noti:Notification) {
        if checkPassword(){
            passwordField.textColor = UIColor.black
        }
        else {
            passwordField.textColor = UIColor.red
        }
    }
    
    func checkEmail(showAlert:Bool = false) -> Bool {
        if emailField.text!.isEmail() {
            return true
        }
        else {
            if showAlert{
                _ = SCLAlertView().showError("Sorry", subTitle: "Incorrect Email format.")
            }
            return false
        }
    }
    
    func checkPassword(showAlert:Bool = false) -> Bool{
        if passwordField.text!.length >= 6 {
            return true
        }
        else {
            if showAlert{
                _ = SCLAlertView().showError("Sorry", subTitle: "A valid password has at lease 6 characters.")
            }
            return false
        }
    }
    
    func showConfirmPsw() {
        let alert = SCLAlertView()
        repassField = alert.addTextField()
        repassField?.isSecureTextEntry = true
        _ = alert.addButton("Done", action: alertClose)
        _ = alert.showEdit("Sign up", subTitle: "Please re-enter your password.", closeButtonTitle: "Cancel")
    }
    
    func login(user:FIRUser){
        currUser = UserModel.getUser(uid: user.uid, getWall: true, getProfile: true)
        currUser?.ref.child("email").setValue(user.email)
        let req = user.profileChangeRequest()
        req.displayName = "hello"
        currUser?.username = user.displayName
        questionManager = QuestionManager()
        controllerManager = ControllerManager()
        networkingManager = NetworkingManager()
        networkingManager?.getQuestion()
        gameManager = GameManager()
        self.show(controllerManager!.tabbarVC, sender: self)
//        self.show(drawer, sender: self)
    }
    
    func initUserInfo(){
        let standard = UserDefaults.standard
        if let username = standard.string(forKey: "username"){
            emailField.text = username
            if let password = standard.string(forKey: "password"){
                passwordField.text = password
            }
        }
    }
    
    func alertClose(){
        if let text = repassField?.text{
            if text != passwordField.text{
                _ = SCLAlertView().showError("Sorry", subTitle: "Two passwords are not the same")
            }
            else {
                let spinner = SwiftSpinner.show("Signing up...")
                spinner.backgroundColor = themeColor
                FIRAuth.auth()?.createUser(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
                    SwiftSpinner.hide()
                    if let error = error{
                        _ = SCLAlertView().showError("Sorry", subTitle: error.localizedDescription)
                    }
                    else if let user = user{
                        let alert = SCLAlertView().showSuccess("Success", subTitle: "Signup successfully!")
                        let standard = UserDefaults.standard
                        standard.set(user.email, forKey: "username")
                        standard.set(self.passwordField.text, forKey: "password")
                        alert.setDismissBlock({ 
                            self.login(user: user)
                        })
                    }
                    else {
                        _ = SCLAlertView().showError("Sorry", subTitle: "Unknown error occurs")
                    }
                })
            }
        }
    }
    
    func googleSignIn(){
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()!.options.clientID
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    // Override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        googleSignIn()
        initView()
        initUI()
        initNoti()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initUserInfo()
        if let user = FIRAuth.auth()?.currentUser{
            login(user: user)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error{
            _ = SwiftSpinner.hide()
            _ = SCLAlertView().showError("Sorry", subTitle: error.localizedDescription)
        }
        else{
            let auth = user.authentication
            let cred = FIRGoogleAuthProvider.credential(withIDToken: auth!.idToken, accessToken: auth!.accessToken)
            let spinner = SwiftSpinner.show("Login...")
            spinner.backgroundColor = themeColor
            FIRAuth.auth()?.signIn(with: cred, completion: { (user, error) in
                _ = SwiftSpinner.hide()
                if let error = error{
                    _ = SCLAlertView().showError("Sorry", subTitle: error.localizedDescription)
                }
                else{
                    self.login(user: user!)
                }
            })
        }
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        _ = SwiftSpinner.hide()
        present(viewController, animated: true, completion: nil)
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        print("User login")
        if error != nil{
            _ = SCLAlertView().showError("Sorry", subTitle: error.localizedDescription)
        }
        else if result.isCancelled{
             _ = SCLAlertView().showError("Sorry", subTitle: "You canceled the envent")
        }
        else{
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            _ = SwiftSpinner.show("Login...")
            FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
                _ = SwiftSpinner.hide()
                if let error = error{
                    _ = SCLAlertView().showError("Sorry", subTitle: error.localizedDescription)
                }
                else if let user = user{
                    self.login(user: user)
                }
            })
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User logout")
    }
}
