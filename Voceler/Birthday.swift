//
//  Birthday.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 7/13/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import SDAutoLayout

class Birthday: UIViewController {

    var birthPicker = UIDatePicker()
    var textField:UITextField!
    let formatter = DateFormatter()
    var text:NSMutableString!
    
    func confirmAction() {
        textField.text = formatter.string(from: birthPicker.date)
        text.setString(textField.text!)
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        birthPicker.datePickerMode = .date
        title = "Birthday"
        formatter.dateFormat = "MM-dd-yyyy"
        if let date = textField.text , date != ""{
            birthPicker.setDate(formatter.date(from: date)!, animated: true)
        }
        else{
            birthPicker.setDate(Date(), animated: true)
        }
        
        view.addSubview(birthPicker)
        _ = birthPicker.sd_layout()?
            .topSpaceToView(view, 64)?
            .leftSpaceToView(view, 0)?
            .rightSpaceToView(view, 0)?
            .heightIs(200)
        navigationBar.setColor(color: themeColor)
        birthPicker.maximumDate = Date()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(confirmAction))
    }
    
    override func hasCustomNavigationBar() -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
