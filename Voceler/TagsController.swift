//
//  TagsController.swift
//  BlazingVote
//
//  Created by Zhenyang Zhong on 6/5/16.
//  Copyright © 2016 ZhenyangZhong. All rights reserved.
//

import UIKit
import TagListView
import SDAutoLayout
import SCLAlertView
import FirebaseDatabase

class TagsController: UIViewController, TagListViewDelegate, UITextFieldDelegate {
    var optTBV = UITableView()
    private var question:QuestionModel!
    @IBOutlet weak var priorityLbl: UILabel!
    @IBOutlet weak var slider: UISlider!

    @IBAction func slideAction(_ sender: AnyObject) {
        priorityLbl.text = "Question priority: " + String(sliderValue())
    }
    func setQuestion(descr:String, optArr:[String]){
        question = QuestionModel()
        question.qAskerID = currUser?.uid
        question.qDescrption = descr
        question.qOptions = [OptionModel]()
        for opt in optArr{
            if opt.isNotEmpty{
                question.qOptions.append(OptionModel(description: opt))
            }
        }
        question.qAnonymous = appSetting.isAnonymous
    }

    @IBOutlet weak var tagView: TagListView!

    private func sliderValue()->Int{
        return Int(slider.value)
    }
    
    @IBAction func doneAction(sender: AnyObject) {
        let alert = SCLAlertView()
        _ = alert.addButton("Confirm") {
            self.finishQuestion()
            self.question.postQuestion()
            _ = SCLAlertView().showSuccess("Success!", subTitle: "Successfully posted the question.", duration: 1)
            self.clearNav()
        }
        let alertText = sliderValue() == 0 ? "Are you sure you wants to post the question?" : "Are you sure you wants to spend \(sliderValue()) coins to post the question?"
        _ = alert.showNotice("Post", subTitle: alertText, closeButtonTitle: "Cancel")
    }
    
    func generatePriority() -> Double{
        return question.qTime.timeIntervalSince1970 + Double(slider.value)
    }

    func finishQuestion(){
        for tag in tagView.tagViews{
            question.qTags.append(tag.titleLabel!.text!)
        }
        question.qTime = Date()
        question.qPriority = generatePriority()
    }

    func clearNav(){
        let first = navigationController?.viewControllers[0] as! AskProblemVC
        first.handler.setText("", withAnimation: false)
        first.optArr.removeAll()
        first.table.reloadData()
        tagView.removeAllTags()
        textField.text = ""
        slider.value = 0
        optTBV.isHidden = true
        tagView.isHidden = false
        navigationController?.dismiss(animated: true, completion: {
            _ = self.navigationController!.popToRootViewController(animated: false)
        })
    }

    @IBOutlet weak var textField: UITextField!
    @IBAction func addAction(sender: AnyObject) {
        if let text = textField.text{
            if text.isEmpty{
                _ = SCLAlertView().showError("Sorry", subTitle: "Tag text cannot be empty")
            }
            else if tagView.tagViews.count == 5{
                _ = SCLAlertView().showError("Sorry", subTitle: "You can only add at most 5 tags.")
            }
            else {
                for tag in tagView.tagViews{
                    if tag.titleLabel?.text == text{
                        return
                    }
                }
                _ = tagView.addTag(text)
                textField.text = ""
                optTBV.isHidden = true
                tagView.isHidden = false
            }
        }
    }

    @IBOutlet weak var addBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []

        // Do any additional setup after loading the view.
        tagView.textFont = UIFont.systemFont(ofSize: 16)
        tagView.alignment = .left
        tagView.delegate = self
        tagView.enableRemoveButton = true
        textField.clearButtonMode = .whileEditing
        textField.delegate = self

        view.addSubview(optTBV)
        _ = optTBV.sd_layout()
            .topSpaceToView(textField, 8)!
            .bottomSpaceToView(view, 0)!
            .leftSpaceToView(view, 0)!
            .rightSpaceToView(view, 0)!
        optTBV.isHidden = true

        addBtn.imageView?.setIcon(img: #imageLiteral(resourceName: "plus-50").withRenderingMode(.alwaysTemplate), color: themeColor)

        let noti = NotificationCenter.default
        noti.addObserver(self, selector: #selector(textChange(noti:)), name: Notification.Name.UITextFieldTextDidChange, object: textField)

        let tap = UITapGestureRecognizer(target: self, action: #selector(endEdit))
        tagView.addGestureRecognizer(tap)

        slider.minimumValue = 0
        slider.maximumValue = 7200

    }

    let categories = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Categories", ofType: "plist")!)!

    func textChange(noti:Notification) {
        if textField.text == "" {
            optTBV.isHidden = true
            tagView.isHidden = false
        }
        else {
            optTBV.isHidden = false
            tagView.isHidden = true
        }
    }

    func endEdit(){
        textField.endEditing(true)
    }

    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) -> Void{
        self.tagView.removeTagView(tagView)
    }
}
