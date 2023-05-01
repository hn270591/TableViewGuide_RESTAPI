import UIKit

class SearchArticlesCell: UITableViewCell {
    
    @IBOutlet weak var headLineLabel: UILabel!
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var publishDateLabel: UILabel!
    
    private var date = Date()
    var article: ArticleItem? {
        didSet {
            guard let article = article else { return }
            headLineLabel.text = article.headline.main
            publishDateLabel.text = date.publishDate(date: article.pub_date)
            publishDateLabel.textColor = UIColor.secondaryLabel
            
            let multimedia = article.multimedia
            if !multimedia.isEmpty, multimedia.count >= 20 {
                let stringURL = "https://static01.nyt.com/" + multimedia[19].url
                let imageURL = URL(string: stringURL)
                thumbnailView.downloadImage(url: imageURL!)
                thumbnailView.contentMode = .scaleToFill
            } else {
                thumbnailView.image = UIImage(systemName: "photo")
                thumbnailView.tintColor = .lightGray
            }
        }
    }
}
