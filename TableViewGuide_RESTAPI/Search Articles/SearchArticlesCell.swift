//
//  SearchArticlesCell.swift
//  TableViewGuide_RESTAPI
//
//  Created by Hoàng Loan on 29/03/2023.
//

import UIKit
import Kingfisher

class SearchArticlesCell: UITableViewCell {
    
    @IBOutlet weak var headLineLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    var articles: Articles? {
        didSet {
            headLineLabel.text = articles?.headLine
            
            if let stringURL = articles?.thumbnailURL {
                let imageURL = URL(string: stringURL)
                thumbnailImageView.downloadImage(url: imageURL!)
                thumbnailImageView.contentMode = .scaleToFill
            } else {
                thumbnailImageView.image = UIImage(systemName: "photo")
            }
        }
    }
}

// MARK: - Extension ImageView

extension UIImageView {
    func downloadThumbnail(url: URL) {
        self.kf.indicatorType = .activity
        self.kf.setImage(with: url,
                              placeholder: UIImage(named: "placeholderImage"),
                              options: [
                                .processor(DownsamplingImageProcessor(size: self.bounds.size)),
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
}
