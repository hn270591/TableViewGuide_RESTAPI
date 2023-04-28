import UIKit

class SearchArticlesCell: UITableViewCell {
    
    @IBOutlet weak var headLineLabel: UILabel!
    @IBOutlet weak var thumbnailView: UIImageView!
    
    var article: ArticleItem? {
        didSet {
            guard let article = article else { return }
            headLineLabel.text = article.headline.main
            if let multimedia = article.multimedia, !multimedia.isEmpty {
                if multimedia.count >= 20 {
                    let stringURL = "https://static01.nyt.com/" + multimedia[19].url
                    let imageURL = URL(string: stringURL)
                    thumbnailView.downloadImage(url: imageURL!)
                    thumbnailView.contentMode = .scaleToFill
                }
            } else {
                thumbnailView.image = UIImage(systemName: "photo")
                thumbnailView.tintColor = .lightGray
            }
        }
    }
}
