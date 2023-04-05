
import UIKit
import Kingfisher

class SearchArticlesCell: UITableViewCell {
    
    @IBOutlet weak var headLineLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    var articles: ArticleItem? {
        didSet {
            headLineLabel.text = articles?.headline.main
            if let multimedia = articles?.multimedia {
                if multimedia.count >= 20 {
                    let stringURL = "https://static01.nyt.com/" + multimedia[19].url
                    let imageURL = URL(string: stringURL)
                    thumbnailImageView.downloadImage(url: imageURL!)
                    thumbnailImageView.contentMode = .scaleToFill
                }
            } else {
                thumbnailImageView.image = UIImage(systemName: "photo")
            }
        }
    }
}

// MARK: - Extension ImageView

extension UIImageView {
    func downloadThumbnail(url: URL) {
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
