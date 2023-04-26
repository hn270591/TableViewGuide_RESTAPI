import Foundation
import Alamofire

enum BaseResponseError: Error {
    case invalidResponse
    case invalidData
    case inConnect
}

class Connectivity {
    class func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}

typealias completion<T> = (Result<T, BaseResponseError>) -> Void
typealias storyCompletion = ([Story], BaseResponseError?) -> Void
typealias articleCompletion = ([ArticleItem], BaseResponseError?) -> Void

class BaseRequest {
    static let shared = BaseRequest()
    
    func request<T: Codable>(urlRequest: APIRouter, method: HTTPMethod, objectType: T.Type, completion: @escaping completion<T>) -> Void {
        if !Connectivity.isConnectedToInternet() {
            // Error internet
            print("Internet inconnect")
            completion(.failure(BaseResponseError.inConnect))
            return
        }
        
        AF.request(urlRequest).response { response in
            print(response.request?.url ?? "Error URL")
            switch response.result {
            case .success(_):
                if response.response?.statusCode == 200 {
                    print("StatusCode: \(response.response?.statusCode ?? 0)")
                    guard let data = response.data else {
                        completion(.failure(BaseResponseError.invalidData))
                        return
                    }
                    let jsonReponse = try! JSONDecoder().decode(objectType, from: data)
                    completion(.success(jsonReponse))
                } else {
                    completion(.failure(BaseResponseError.invalidResponse))
                    print("StatusCode: \(response.response?.statusCode ?? 200)")
                }
            case .failure(let error):
                print(error.localizedDescription)
                completion(.failure(BaseResponseError.invalidResponse))
            }
        }
    }
}

class BaseReponse {
    static let shared = BaseReponse()
    
    func storyResponse(completion: @escaping storyCompletion) {
        BaseRequest.shared.request(urlRequest: APIRouter.topStories, method: .get, objectType: Results.self, completion: { results in
            switch results {
            case .success(let value):
                let stories = value.results
                completion(stories, nil)
            case .failure(let error):
                completion([], error)
            }
        })
    }
    
    func articleResponse(query: String, page: Int, completion: @escaping articleCompletion) {
        BaseRequest.shared.request(urlRequest: APIRouter.searchArticle(q: query, page: page), method: .get, objectType: ArticlesData.self, completion: { results in
            switch results {
            case .success(let value):
                let articles = value.response.docs
                completion(articles, nil)
            case .failure(let error):
                completion([], error)
            }
        })
    }
}


// Model SearchArticles
struct ArticlesData: Codable {
    var status: String
    var response: Response
}

struct Response: Codable {
    var docs: [ArticleItem]
}

struct ArticleItem: Codable {
    var headline: Headline
    var multimedia: [MultimediaArticle]?
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
    var published_date: String
    var multimedia: [MultiMediaStory]?
    var isRead: Bool?
}

struct MultiMediaStory: Codable {
    let url: String
}
