import UIKit

private let apiKey = "FhNV8V9NsHGY2ZIJujLTHTuuLjWOXcaN"
private let resourceUrl = URL(string: "https://api.nytimes.com/svc/topstories/v2/home.json?api-key=\(apiKey)")!

class Story {
    var headline: String?
    var thumbnailUrl: String?

    init(jsonResult: NSDictionary) {
        if let title = jsonResult["title"] as? String {
            headline = title
        }

        if let multimedia = jsonResult["multimedia"] as? NSArray {
            // 4th element is will contain the image of the right size
            if multimedia.count >= 3 {
                if let mediaItem = multimedia[2] as? NSDictionary {
                    if let type = mediaItem["type"] as? String {
                        if type == "image" {
                            if let url = mediaItem["url"] as? String{
                                thumbnailUrl = url
                            }
                        }
                    }
                }
            }
        }
    }

    class func fetchStories(successCallback: @escaping ([Story]) -> Void, error: ((Error?) -> Void)?) {
        let urlRequest = URLRequest(url: resourceUrl)
        URLSession.shared.dataTask(with: urlRequest) { data, response, requestError in
            if let requestError = requestError {
                error?(requestError)
            } else {
                if let data = data {
                    let json = try! JSONSerialization.jsonObject(with: data) as! NSDictionary
                    if let results = json["results"] as? NSArray {
                        var stories: [Story] = []
                        for result in results {
                            stories.append(Story(jsonResult: result as! NSDictionary))
                        }
                        successCallback(stories)
                    }
                } else {
                    // unexepected error happened
                    error?(nil)
                }
            }
        }.resume()
    }
}
