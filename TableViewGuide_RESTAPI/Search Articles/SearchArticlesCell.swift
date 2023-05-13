import UIKit

class SearchArticlesCell: UITableViewCell {
    
    @IBOutlet weak var headLineLabel: UILabel!
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var publishedDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        headLineLabel.font = .fontOfHeadline()
        publishedDateLabel.font = .fontOfSubtitle()
        publishedDateLabel.textColor = UIColor.secondaryLabel
        
        thumbnailView.contentMode = .scaleToFill
    }
    
    var article: ArticleItem? {
        didSet {
            guard let article = article else { return }
            let publishedDate = DateFormatter.publishedDateFormatterForArticles(dateString: article.pub_date)
            
            headLineLabel.text = article.headline.main
            publishedDateLabel.text = publishedDate
            
            if let multimedia = article.multimedia, !multimedia.isEmpty {
                if multimedia.count >= 20 {
                    let stringURL = "https://static01.nyt.com/" + multimedia[19].url
                    let imageURL = URL(string: stringURL)
                    thumbnailView.downloadImage(url: imageURL!)
                }
            } else {
                thumbnailView.image = UIImage(systemName: "photo")
                thumbnailView.tintColor = .lightGray
            }
        }
    }
}
