
import UIKit

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
