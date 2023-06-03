import UIKit

class SearchArticlesCell: UITableViewCell {
    
    @IBOutlet weak var headLineLabel: UILabel!
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var publishedDateLabel: UILabel!
    
    func configureUI() {
        headLineLabel.font = .fontOfHeadline()
        publishedDateLabel.font = .fontOfSubtitle()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
        publishedDateLabel.textColor = UIColor.secondaryLabel
        thumbnailView.contentMode = .scaleToFill
    }

    var article: ArticleItem? {
        didSet {
            guard let article = article else { return }
            let publishedDate = DateFormatter.publishedDateFormatterForArticles(dateString: article.pubDate)
            
            headLineLabel.text = article.headline.main
            publishedDateLabel.text = publishedDate
            
            if !article.imageURLString.isEmpty {
                guard let imageURL = URL(string: article.imageURLString) else { return }
                thumbnailView.downloadImage(url: imageURL)
            } else {
                thumbnailView.image = UIImage(systemName: "photo")
                thumbnailView.tintColor = .lightGray
            }
        }
    }
}
