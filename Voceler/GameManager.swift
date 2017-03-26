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
            print("duration \(duration), constant \(constant)")
            constant = abs(duration) > constantManager.min_duration ? 1 + exp(Float(duration) / constantManager.duration_constant) * constant : 1 // C := 1 + e^(-duration/2)
        }
        lastActiveTime = Date()
        let rand = Float(arc4random_uniform(50))
        return Int(constant * (rand + 100.0)/100.0) * multiple
    }
    
    func chooseOption(){
        moneyChange(val: getCredit(multiple: constantManager.choose_option))
    }
    
    func addOption(){
        moneyChange(val: getCredit(multiple: constantManager.add_option))
    }
    
    private func moneyChange(val:Int){
        currUser?.ref.child("money").setValue(currUser!.money + val)
    }
    
    private func consume(money:Int, charge:Bool = false)->Bool{
        if (currUser!.money < money){
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
        return consume(money: constantManager.ask_cost, charge: charge)
    }
    
    func addProgressSize(charge:Bool = false)->Bool{
        return consume(money: constantManager.add_in_process_cost, charge: charge)
    }
    
    func addCollectionSize(charge:Bool = false)->Bool{
        return consume(money: constantManager.add_in_collection_cost, charge: charge)
    }
    
    func checkAskQuestion()->Bool{
//		return true
        if !askQuestion() {
            SCLAlertView().showError("No money!", subTitle: "Please anwser some questions to get money to ask question.", duration: 1)
            return false
        }
        else if currUser!.qInProgressLimit! <= currUser!.qInProgress.count{
            SCLAlertView().showError("Question limit reached!", subTitle: "Please conclude some questions or add in progress question limit.", duration: 1)
            return false
        }
        else{
            return true
        }
    }
}
