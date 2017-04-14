//
//  NetworkingManager.swift
//  QAQ
//
//  Created by 钟镇阳 on 11/13/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import Networking
import PercentEncoder
import SwiftyJSON
import FirebaseDatabase
import SwiftString3
import SCLAlertView

//http://lowcost-env.pukinshx93.us-west-2.elasticbeanstalk.com/qaq/zhaowei/
class NetworkingManager: NSObject {
    
//    let baseURL = "http://sample-env.t3xyggzwqq.us-west-2.elasticbeanstalk.com/" // PRODUCTION DATABASE
    let baseURL = "http://lowcost-env.pukinshx93.us-west-2.elasticbeanstalk.com/" // TESTING DATABASE
//    let baseURL = "http://localhost:8000/qaq/"
    
    private func analyzeWords(text:String)->[String]{
        let usefulSet:Set<String> = [NSLinguisticTagPlaceName, NSLinguisticTagWordJoiner, NSLinguisticTagNoun, NSLinguisticTagOtherWord, NSLinguisticTagPersonalName, NSLinguisticTagOrganizationName, NSLinguisticTagVerb, NSLinguisticTagAdjective, NSLinguisticTagOtherWord]
        let uselessSet:Set<String> = ["is", "are", "be", "being", "been", "was", "were", "do", "does", "did", "doing", "has", "have", "had", "should", "would", "shall", "will", "worst", "best", "most", "least"]
        var tokenRanges: NSArray?
        let options: NSLinguisticTagger.Options = [.omitWhitespace, .omitPunctuation, .joinNames, .omitOther]
        let tags = NSString(string: text).linguisticTags(
            in: NSMakeRange(0, (text as NSString).length),
            scheme: NSLinguisticTagSchemeNameTypeOrLexicalClass,
            options: options, orthography: nil, tokenRanges: &tokenRanges
        )
        var result = [String]()
        for i in 0..<tags.count{
            if let range = tokenRanges?[i] as? NSRange{
                let token = (text as NSString).substring(with: range)
                print(tags[i], token)
                if usefulSet.contains(tags[i]) && !uselessSet.contains(token.lowercased()){
                        result.append(token)
                }
            }
        }
        return result
    }
    
    func searchTags(text: String, tagsVC: TagsController){
//        http://lowcost-env.pukinshx93.us-west-2.elasticbeanstalk.com/question_tags/?t=Phone
        let encodedText = text.lowercased().ped_encodeURIComponent()
        let networking = Networking(baseURL: baseURL + "question_tags/?")
        networking.get("t=" + encodedText, completion: { (result) in
            var tags = [String]()
            switch result {
            case .success(let response):
                let json = response.dictionaryBody
                tags = json["tags"] as! [String]
                break
            // Do something with JSON, you can also get arrayBody
            case .failure(_):
                // Handle error
                if let error = result.error{
                    _ = SCLAlertView().showError("Error", subTitle: error.localizedDescription)
                }
                break
            }
//            NotificationCenter.default.post(name: Notification.Name.TagsSearched, object: tags)
//			controllerManager?.tagsVC.tags = tags
			tagsVC.updateTableView(tags: tags)
            // TODO 高仲阳 handle tags
        })
    }
    
    func getQuestionTags(text:String){
        let encodedText = text.lowercased().ped_encodeURIComponent()
        let networking = Networking(baseURL: baseURL + "question_tags/?")
        networking.get("q=" + encodedText, completion: { (result) in
            var tags = [String]()
            switch result {
            case .success(let response):
                let json = response.dictionaryBody
                tags = json["tags"] as! [String]
            // Do something with JSON, you can also get arrayBody
            case .failure(_):
                // Handle error
                if let error = result.error{
                    _ = SCLAlertView().showError("Error", subTitle: error.localizedDescription)
                }
                break
            }
            NotificationCenter.default.post(name: Notification.Name.TagsLoaded, object: tags)
        })
    }
    
    func updateTags(text:String, tags:[String]){
        let networking = Networking(baseURL: baseURL + "question_tags/?")
        let encodedText = text.lowercased().ped_encodeURIComponent()
        let encodedTags = tags.joined(separator: ",").ped_encodeURIComponent()
        let path = "w=\(encodedText)&t=\(encodedTags)"
        networking.get(path, completion: { (result) in })
    }
    
    func postRequest(dict:Dictionary<String, Any>, handler:@escaping (_ result:Dictionary<String, Any>)->Void){
        let networking = Networking(baseURL: baseURL)
        networking.post("qaq/zhaowei/", parameters: dict) { (result) in
            switch result {
            case .success(let response):
                let json = response.dictionaryBody
                handler(json)
            // Do something with JSON, you can also get arrayBody
            case .failure(let _):
                // Handle error
                if let error = result.error{
                    _ = SCLAlertView().showError("Error", subTitle: error.localizedDescription)
                }
            }
        }
    }
    
    func concludeQuestion(qid:String){
        func handler(result:Dictionary<String,Any>){
            print(result)
        }
        postRequest(dict: ["action": "conclude_ques", "qid":qid], handler: handler)
    }
    
    func addQuestion(qid:String, tags:[String]){
        func handler(result:Dictionary<String, Any>){
            print(result)
        }
        postRequest(dict: ["action": "add_questions", "qid": qid, "qTags": tags, "uid": currUser!.ref.key], handler: handler)
    }
    
    func getQuestion(num:Int){
        func handler(dict:Dictionary<String, Any>){
            if let qids = dict["qids"] as? Array<String>{
                for qid in qids{
                    questionManager?.qMainArr.append(databaseQuestionRef.child(qid))
                }
            }
        }
        postRequest(dict: ["action": "get_questions", "uid": currUser!.ref.key, "num":num], handler: handler)
    }
}
