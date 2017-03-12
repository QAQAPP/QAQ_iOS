//
//  GameManager.swift
//  QAQ
//
//  Created by Zhenyang Zhong on 2/6/17.
//  Copyright © 2017 Zhenyang Zhong. All rights reserved.
//

import UIKit
import SCLAlertView

class GameManager: NSObject {
    private var lastActiveTime:Date?
    private var constant:Float = 1
    
    private func updateActiveTime(){
        lastActiveTime = Date()
    }
    
    private func getCredit(multiple:Int)->Int{
        if let time = lastActiveTime{
            let duration = time.timeIntervalSince(Date())
            constant = 1 + exp(Float(duration/5) / -10.0) * constant // C := 1 + e^(-duration/2)
        }
        lastActiveTime = Date()
        let rand = Float(arc4random_uniform(50))
        return Int(constant * (rand + 100.0)/100.0) * multiple
    }
    
    func chooseOption(){
        moneyChange(val: getCredit(multiple: 1))
    }
    
    func addOption(){
        moneyChange(val: getCredit(multiple: 5))
    }
    
    private func moneyChange(val:Int){
        currUser?.ref.child("money").setValue(currUser!.money! + val)
    }
    
    private func consume(money:Int, charge:Bool = false)->Bool{
        if (currUser!.money! < money){
            return false
        }
        else {
            if charge{
                moneyChange(val: -money)
            }
            return true
        }
    }
    
    func askQuestion(charge:Bool = false)->Bool{
        return consume(money: 30000)
    }
    
    func addProgressSize(charge:Bool = false)->Bool{
        return consume(money: 50000)
    }
    
    func addCollectionSize(charge:Bool = false)->Bool{
        return consume(money: 10000)
    }
    
    func checkAskQuestion()->Bool{
//		return true
        if !askQuestion() {
            SCLAlertView().showError("No money!", subTitle: "Please anwser some questions to get money to ask question.")
            return false
        }
        else if currUser!.qInProgressLimit! <= currUser!.qInProgress.count{
            SCLAlertView().showError("Question limit reached!", subTitle: "Please conclude some questions or add in progress question limit.")
            return false
        }
        else{
            return true
        }
    }
}
