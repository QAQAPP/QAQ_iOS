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
import SwiftString3
import SCLAlertView

//http://lowcost-env.pukinshx93.us-west-2.elasticbeanstalk.com/qaq/zhaowei/
class NetworkingManager: NSObject {
    
//    let baseURL = "http://lowcost-env.pukinshx93.us-west-2.elasticbeanstalk.com/qaq/"
    let baseURL = "http://localhost:8000/qaq/"
    
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
    
    func getQuestionTags(text:String){
        let encodedText = text.lowercased().ped_encodeURIComponent()
        let networking = Networking(baseURL: "http://django-env.6jck6j9kff.us-west-2.elasticbeanstalk.com/qaq/matthew/?q=")
        networking.get("q=" + encodedText, completion: { (val, dict, error) in
            var tags = [String]()
            if error == nil{
                let json = JSON(val as Any)
                for (_, val) in json["tags"]{
                    if let tag = val.array?[0].string{
                        tags.append(tag)
                    }
                }
            }
            NotificationCenter.default.post(name: Notification.Name.TagsLoaded, object: tags)
        })
    }
    
    func updateTags(text:String, tags:[String]){
        let networking = Networking(baseURL: baseURL + "matthew/?q=")
        let encodedText = text.lowercased().ped_encodeURIComponent()
        let encodedTags = tags.joined(separator: ",").ped_encodeURIComponent()
        let path = "w=\(encodedText)&t=\(encodedTags)"
        networking.get(path, completion: { (val, error) in })
    }
    
    func postRequest(dict:Dictionary<String, Any>, handler:@escaping (_ result:Dictionary<String, Any>)->Void){
        let networking = Networking(baseURL: baseURL)
        networking.post("zhaowei/", parameters: dict) { (result, error) in
            if let error = error{
                _ = SCLAlertView().showError("Error", subTitle: error.localizedDescription)
            }
            else if let result = result as? Dictionary<String, Any>{
                handler(result)
            }
        }
    }
    
    func addQuestion(qid:String, tags:[String]){
        func handler(result:Dictionary<String, Any>){
            print(result)
        }
        postRequest(dict: ["action": "add_questions", "qid": qid, "qTags": tags, "uid": currUser!.uid], handler: handler)
    }
    
    func getQuestion(){
        func handler(dict:Dictionary<String, Any>){
            if let qid = dict["qid"] as? String, qid != ""{
                questionManager?.loadQuestionContent(qid: qid)
            }
        }
        postRequest(dict: ["action": "get_questions", "uid": currUser!.uid], handler: handler)
    }
}
