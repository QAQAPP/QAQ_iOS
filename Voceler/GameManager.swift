//
//  GameManager.swift
//  QAQ
//
//  Created by Zhenyang Zhong on 2/6/17.
//  Copyright © 2017 Zhenyang Zhong. All rights reserved.
//

import UIKit

class GameManager: NSObject {
    private var lastActiveTime:Date?
    private var constant:Float = 1
    
    private func updateActiveTime(){
        lastActiveTime = Date()
    }
    
    private func getCredit(multiple:Int)->Int{
        if let time = lastActiveTime{
            let duration = time.timeIntervalSince(Date())
            constant = 1 + exp(Float(duration) / -10.0) * constant // C := 1 + e^-duration
        }
        lastActiveTime = Date()
        let rand = Float(arc4random_uniform(50))
        return Int(constant * (rand + 100.0)/100.0) * multiple
    }
    
    func chooseOption(){
        currUser!.money! += getCredit(multiple: 1)
    }
    
    func addOption(){
        currUser!.money! += getCredit(multiple: 5)
    }
    
    private func consume(money:Int)->Bool{
        if (currUser!.money! < money){
            return false
        }
        else {
            currUser!.money! -= money
            return true
        }
    }
    
    func askQuestion()->Bool{
        return consume(money: 300)
    }
    
    func addProgressSize()->Bool{
        return consume(money: 500)
    }
    
    func addCollectionSize()->Bool{
        return consume(money: 100)
    }
}
