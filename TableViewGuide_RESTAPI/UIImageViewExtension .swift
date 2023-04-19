//
//  Extension UIImageView.swift
//  TableViewGuide_RESTAPI
//
//  Created by Nguyễn Thịnh on 10/04/2023.
//

import Foundation
import UIKit
import Kingfisher
import Alamofire
import AlamofireImage

extension UIImageView {
    
    // MARK: - download thumbnail by Kingfisher
    
    func downloadImage(url: URL) {
        self.kf.indicatorType = .activity
        self.kf.setImage(with: url,
                              placeholder: UIImage(named: "placeholderImage"),
                              options: [
                                .scaleFactor(UIScreen.main.scale),
                                .cacheOriginalImage,
                                .transition(.fade(0.25))
                              ])
        {
            result in
            switch result {
            case .success(let value):
                self.image = value.image
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    // MARK: - download thumbnail by AlamofireImage
    
    func downloadThumbnail(url: URL) {
        AF.request(url).responseImage { response in
            switch response.result {
            case .success(_):
                let image: UIImage! = response.value
                DispatchQueue.main.async {
                    self.image = image
                }
            case .failure(let error):
                print("Error Occured: \(error.localizedDescription)")
            }
        }
    }
}


