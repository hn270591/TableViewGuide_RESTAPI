//
//  HTTPRouter.swift
//  TableViewGuide_RESTAPI
//
//  Created by Nguyễn Thịnh on 14/04/2023.
//

import Foundation
import Alamofire

enum APIRouter: URLRequestConvertible {
    case topStories
    case search(q: String, page: Int)
    
    var baseURL: URL {
        return URL(string: "https://api.nytimes.com/svc/")!
    }

    var method: HTTPMethod {
        switch self {
        case .topStories: return .get
        case .search: return .get
        }
    }

    var path: String {
        switch self {
        case .topStories:
            return "topstories/v2/home.json"
        case .search:
            return "search/v2/articlesearch.json"
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .topStories:
            return nil
        case .search(let queryName, let numberPage):
            return ["q": queryName, "page": numberPage]
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
