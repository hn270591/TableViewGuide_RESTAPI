import UIKit
import Alamofire

class StoryCell: UITableViewCell {

    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var publishedDateLabel: UILabel!
    
    var isRead: Bool = false {
        didSet {
            headlineLabel.textColor = isRead ? .lightGray : .label
        }
    }
    
    func configureUI() {
        headlineLabel.font = .fontOfHeadline()
        publishedDateLabel.font = .fontOfSubtitle()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
        publishedDateLabel.textColor = UIColor.secondaryLabel
        thumbnailView.contentMode = .scaleToFill
    }
    
    var story: Story? {
        didSet {
            guard let story = story else { return }
            let publishedDate = DateFormatter.publishedDateFormatterForArticles(dateString: story.pubDate)
            
            headlineLabel?.text = story.title
            publishedDateLabel.text = publishedDate
            isRead = story.isRead ?? false
            
            if !story.imageURLString.isEmpty {
                guard let imageURL = URL(string: story.imageURLString) else { return }
                thumbnailView.downloadImage(url: imageURL)
            } else {
                thumbnailView.image = UIImage(systemName: "photo")
                thumbnailView.tintColor = .lightGray
            }
        }
    }
    
    var article: Article? {
        didSet {
            guard let article = article else { return }
            let publishedDate = DateFormatter.publishedDateFormatterForArticles(dateString: article.publishedDate!)
            
            headlineLabel.text = article.title
            publishedDateLabel.text = publishedDate
            isRead = article.isRead
            if let urlString = article.imageURL, !urlString.isEmpty {
                thumbnailView.downloadImage(url: URL(string: urlString)!)
            } else {
                thumbnailView.image = UIImage(systemName: "photo")
                thumbnailView.tintColor = .lightGray
            }
        }
    }
}
