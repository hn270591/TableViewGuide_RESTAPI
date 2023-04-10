
import Foundation
import UIKit

private let apiKey = "FhNV8V9NsHGY2ZIJujLTHTuuLjWOXcaN"
struct ConStants {
    static let topStoriesURL = URL(string: "https://api.nytimes.com/svc/topstories/v2/home.json?api-key=\(apiKey)")
}



extension URLSession {
    enum CustomError: Error {
        case invalidURL
        case invalidData
        case invalidResponse
        case badStutusCode
        case inconnectInternet
    }
    
    func request<T: Codable>(url: URL?, expecting: T.Type, completion: @escaping (Result<T, Error>) -> Void) -> Void {
        guard let url = url
        else {
            completion(.failure(CustomError.invalidURL))
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(CustomError.inconnectInternet))
                fatalError(error.localizedDescription)
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Not the right response")
                completion(.failure(CustomError.invalidResponse))
                 return
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                print("Error: StatusCode \(httpResponse.statusCode)")
                completion(.failure(CustomError.badStutusCode))
                return
            }
            if let data = data {
                let result = try! JSONDecoder().decode(expecting, from: data)
                completion(.success(result))
            } else {
                completion(.failure(CustomError.invalidData))
            }
        }.resume()
    }
}

class Articles {
    class func fetchStory(successCallBack: @escaping ([Story]) -> Void, requestError: ((URLSession.CustomError) -> Void)?) {
        URLSession.shared.request(url: ConStants.topStoriesURL, expecting: Results.self, completion: { result in
            switch result {
            case .success(let value):
                var stories: [Story] = []
                stories = value.results
                successCallBack(stories)
            case .failure(let error):
                print(error.localizedDescription)
                print("Error: Internet or Request URL")
                requestError?(error as! URLSession.CustomError)
            
            }
        })
    }
    
    class func fetchArticles(queryName: String, numberPage: Int, successCallBack: @escaping ([ArticleItem]) -> Void, requestError: ((URLSession.CustomError) -> Void)?) {
        let searchArticleURL = URL(string: "https://api.nytimes.com/svc/search/v2/articlesearch.json?q=\(queryName)&page=\(numberPage)&api-key=\(apiKey)")
        URLSession.shared.request(url: searchArticleURL, expecting: ArticlesData.self, completion: { results in
            switch results {
            case .success(let value):
                var articleItem: [ArticleItem] = []
                articleItem = value.response.docs
                successCallBack(articleItem)
            case .failure(let error):
                print(error.localizedDescription)
                requestError?(error as! URLSession.CustomError)
            }
        })
    }
}

// MARK: - Model

// Model SearchArticles
struct ArticlesData: Codable {
//    var status: String
    var response: Response
}

struct Response: Codable {
    var docs: [ArticleItem]
}

struct ArticleItem: Codable {
    var headline: Headline
    var multimedia: [MultimediaArticle]
    var web_url: String
}

struct Headline: Codable {
    var main: String
}

struct MultimediaArticle: Codable {
    var url: String
}
    
// Model Stories
struct Results: Codable {
    var status: String
    var num_results: Int
    var results: [Story]
}

struct Story: Codable {
    var title: String
    var url: String
    var multimedia: [MultimediaStory]
}

struct MultimediaStory: Codable {
    let url: String
}
        
        
        
        
