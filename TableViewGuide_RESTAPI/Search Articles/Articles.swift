//
//  Articles.swift
//  TableViewGuide_RESTAPI

import Foundation
import UIKit

class Articles {
    
    var headLine: String?
    var thumbnailURL: String?
    var detailsURL: String?
    
    init(jsonResults: NSDictionary) {
        if let headline = jsonResults["headline"] as? NSDictionary {
            if let title = headline["main"] as? String {
                headLine = title
            }
        }
            
        if let multimedia = jsonResults["multimedia"] as? NSArray {
            
            if multimedia.count == 0 {
                return
            }
            if multimedia.count >= 19 {
                if let mediaItem = multimedia[19] as? NSDictionary {
                    if let subtype = mediaItem["subtype"] as? String {
                        if subtype == "thumbLarge" {
                            if let url = mediaItem["url"] as? String {
                                thumbnailURL = "https://static01.nyt.com/" + url
                            }
                        }
                    }
                }
            }
        }
        
        if let url = jsonResults["web_url"] as? String {
            detailsURL = url
        }
    }
    
    class func fetchArticles(query: String, successCallback: @escaping ([Articles]) -> Void, error: ((Error?) -> Void)?) {
        let apiKey = "FhNV8V9NsHGY2ZIJujLTHTuuLjWOXcaN"
        let resourceURL = URL(string: "https://api.nytimes.com/svc/search/v2/articlesearch.json?q=\(query)&api-key=\(apiKey)")
        URLSession.shared.dataTask(with: resourceURL!) { data, response, requestError in
            if let requestError = requestError {
                error?(requestError)
            } else {
                if let data = data {
                    let json = try! JSONSerialization.jsonObject(with: data) as! NSDictionary
                    if let response = json["response"] as? NSDictionary {
                        if let docs = response["docs"] as? NSArray {
                            var article: [Articles] = []
                            for doc in docs {
                                article.append(Articles(jsonResults: doc as! NSDictionary))
                            }
                            successCallback(article)
                        }
                    }
                } else {
                    error?(nil)
                }
            }
        }.resume()
    }
}
