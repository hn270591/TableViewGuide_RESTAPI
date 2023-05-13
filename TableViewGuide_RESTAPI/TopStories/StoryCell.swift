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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        headlineLabel.font = .fontOfHeadline()
        publishedDateLabel.font = .fontOfSubtitle()
        publishedDateLabel.textColor = UIColor.secondaryLabel
        
        thumbnailView.contentMode = .scaleToFill
    }
    
    var story: Story? {
        didSet {
            guard let story = story else { return }
            let publishedDate = DateFormatter.publishedDateFormatterForArticles(dateString: story.published_date)
            
            headlineLabel?.text = story.title
            publishedDateLabel.text = publishedDate
            isRead = story.isRead ?? false
            
            if let multimedia = story.multimedia, !multimedia.isEmpty {
                if multimedia.count >= 3 {
                    let thumbnailString = multimedia[2].url
                    let urlString = URL(string: thumbnailString)
                    thumbnailView.downloadImage(url: urlString!)
                }
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
