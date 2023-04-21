import UIKit

class SearchArticlesCell: UITableViewCell {
    
    @IBOutlet weak var headLineLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    var article: ArticleItem? {
        didSet {
            guard let article = article else { return }
            headLineLabel.text = article.headline.main
            let multimedia = article.multimedia
            if multimedia.count >= 20 {
                let stringURL = "https://static01.nyt.com/" + multimedia[19].url
                let imageURL = URL(string: stringURL)
                thumbnailImageView.downloadImage(url: imageURL!)
                thumbnailImageView.contentMode = .scaleToFill
            } else {
                thumbnailImageView.image = UIImage(systemName: "photo")
            }
        }
    }
}
