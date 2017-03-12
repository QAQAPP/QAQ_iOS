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
import SwiftString3

protocol TagsControllerDelegate {
	func dismisOverlay()
}

class TagsController: UIViewController, TagListViewDelegate, UITextFieldDelegate {
    let tagLimit = 10
    var optTBV = UITableView()
    private var question:QuestionModel!
    @IBOutlet weak var priorityLbl: UILabel!
	@IBOutlet var mainView: UIView!
    @IBOutlet weak var slider: UISlider!
	
	var leftButton = UIButton()
	var rightButton = UIButton()

//	@IBOutlet weak var buttonBar: ButtonBar!
	@IBOutlet weak var tfBar: UIView!
	var delegate: TagsControllerDelegate?
	
    @IBAction func slideAction(_ sender: AnyObject) {
        priorityLbl.text = "Question priority: " + String(sliderValue())
    }
    func setQuestion(descr:String, optArr:[String], tags:[String]?){
        question = QuestionModel()
        question.qAskerID = currUser?.uid
        question.qDescrption = descr
        question.qOptions = [OptionModel]()
        for opt in optArr{
            if opt.isNotEmpty{
                question.qOptions.append(OptionModel(question: question, description: opt))
            }
        }
        question.qAnonymous = appSetting.isAnonymous
        if let tags = tags{
            question.qTags = tags
        }
    }

    @IBOutlet weak var tagView: TagListView!

    private func sliderValue()->Int{
        return Int(slider.value)
    }
	
	func backAction(){
		_ = navigationController?.popViewController(animated: false)
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

    func finishQuestion(){
        question.qTags.removeAll()
        for tag in tagView.tagViews{
            if let text = tag.titleLabel?.text, text != ""{
                question.qTags.append(tag.titleLabel!.text!)
            }
        }
    }

    func clearNav(){
        let first = navigationController?.viewControllers[0] as! AskProblemVC
        first.handler.setText("", animated: false)
        first.optArr.removeAll()
//        first.table.reloadData()
        tagView.removeAllTags()
        textField.text = ""
        slider.value = 0
        optTBV.isHidden = true
        tagView.isHidden = false
		self.delegate?.dismisOverlay()
        navigationController?.dismiss(animated: true, completion: {
            _ = self.navigationController!.popToRootViewController(animated: false)
        })
    }

    @IBOutlet weak var textField: UITextField!
    @IBAction func addAction(sender: AnyObject) {
        if var text = textField.text{
            text = text.collapseWhitespace()
            if text.isEmpty{
                _ = SCLAlertView().showError("Sorry", subTitle: "Tag text cannot be empty")
            }
            else if tagView.tagViews.count == tagLimit{
                _ = SCLAlertView().showError("Sorry", subTitle: "You can add at most 10 tags.")
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

	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.setNavigationBarHidden(true, animated: animated)
		
		let view = self.mainView!
		let leftButton = self.leftButton
		let rightButton = self.rightButton
		view.addSubview(leftButton)
		_ = leftButton.sd_layout().bottomSpaceToView(view, 20)?.leftSpaceToView(view, 20)?.heightIs(28)?.widthIs(60)
		view.addSubview(rightButton)
		_ = rightButton.sd_layout().bottomSpaceToView(view, 20)?.rightSpaceToView(view, 20)?.heightIs(28)?.widthIs(60)

		leftButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
		leftButton.setTitle("Back", for: .normal)
		rightButton.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
		rightButton.setTitle("Done", for: .normal)
		leftButton.setTitleColor(themeColor, for: .normal)
		rightButton.setTitleColor(themeColor, for: .normal)

	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.navigationController?.setNavigationBarHidden(true, animated: false)
		
        edgesForExtendedLayout = []

        // Do any additional setup after loading the view.
        tagView.textFont = UIFont.systemFont(ofSize: 16)
        tagView.alignment = .left
        tagView.delegate = self
        tagView.enableRemoveButton = true
        for tag in question.qTags{
            tagView.addTag(tag)
        }
        textField.clearButtonMode = .whileEditing
        textField.delegate = self

        view.addSubview(optTBV)
        _ = optTBV.sd_layout()
            .topSpaceToView(tfBar, 8)!
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
