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
import SwiftString

class NetworkingManager: NSObject {
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
        networking.GET("q=" + encodedText, completion: { (val, dict, error) in
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
        let networking = Networking(baseURL: "http://django-env.6jck6j9kff.us-west-2.elasticbeanstalk.com/qaq/matthew/?q=")
        let encodedText = text.lowercased().ped_encodeURIComponent()
        let encodedTags = tags.joined(separator: ",").ped_encodeURIComponent()
        let path = "w=\(encodedText)&t=\(encodedTags)"
        networking.GET(path, completion: { (val, error) in })
    }
}
