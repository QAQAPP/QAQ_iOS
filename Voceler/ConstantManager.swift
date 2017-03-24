//
//  ConstantManager.swift
//  QAQ
//
//  Created by Zhenyang Zhong on 3/19/17.
//  Copyright © 2017 Zhenyang Zhong. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ConstantManager: NSObject {
    private(set) var add_option:Int = 5
    private(set) var ask_cost:Int = 30000
    private(set) var base_money:Int = 30000
    private(set) var choose_option:Int = 1
    private(set) var duration_constant:Float = 100
    private(set) var in_collection_limit:Int = 20
    private(set) var add_in_collection_cost:Int = 30000
    private(set) var in_process_limit:Int = 5
    private(set) var add_in_process_cost:Int = 30000
    private(set) var min_duration:TimeInterval = 1
    let ref = FIRDatabase.database().reference().child("Constant")
    func setup(){
        let constantMirror = Mirror(reflecting: self)
        for (name, _) in constantMirror.children {
            guard let name = name, name != "ref" else { continue }
            self.setup(child: name)
        }
    }
    func setup(child:String){
        ref.child(child).observe(.value, with: { (snap) in
            if let val = snap.value{
                self.setValue(val, forKey: child)
            }
        })
    }
}
