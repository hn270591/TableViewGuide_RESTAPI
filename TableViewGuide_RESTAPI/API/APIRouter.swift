/* https://api.nytimes.com/svc/topstories/v2/home.json?api-key=FhNV8V9NsHGY2ZIJujLTHTuuLjWOXcaN */

import Foundation
import Alamofire

enum APIRouter: URLRequestConvertible {
    case topStories(_ sectionValue: String)
    case searchArticle(q: String, page: Int)
    
    var baseURL: URL {
        return URL(string: "https://api.nytimes.com/svc/")!
    }

    var method: HTTPMethod {
        switch self {
        case .topStories: return .get
        case .searchArticle: return .get
        }
    }

    var path: String {
        switch self {
        case .topStories(let sectionValue):
            return "topstories/v2/\(sectionValue).json"
        case .searchArticle:
            return "search/v2/articlesearch.json"
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .topStories:
            return nil
        case .searchArticle(let query, let page):
            return ["q": query, "page": page]
        }
    }

    func asURLRequest() throws -> URLRequest {
        let apiKey: Parameters = ["api-key": "FhNV8V9NsHGY2ZIJujLTHTuuLjWOXcaN"]
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.method = method
        request = try URLEncoding.default.encode(request, with: apiKey)
        if let parameters = parameters {
            request = try URLEncoding.default.encode(request, with: parameters)
        }
        return request
    }
}
