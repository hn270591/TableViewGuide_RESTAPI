import UIKit
import Alamofire

class StoryCell: UITableViewCell {

    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var publishedDateLabel: UILabel!
    
    private var date = Date()
    var isRead: Bool = false {
        didSet {
            headlineLabel.textColor = isRead ? .lightGray : .label
        }
    }
    
    var story: Story? {
        didSet {
            guard let story = story else { return }
            headlineLabel?.text = story.title
            publishedDateLabel.text = date.publishDate(dateString: story.published_date)
            publishedDateLabel.textColor = UIColor.secondaryLabel
            isRead = story.isRead ?? false
            
            if let multimedia = story.multimedia, !multimedia.isEmpty {
                if multimedia.count >= 3 {
                    let thumbnailString = multimedia[2].url
                    let urlString = URL(string: thumbnailString)
                    thumbnailView.downloadImage(url: urlString!)
                    thumbnailView.contentMode = .scaleToFill
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
            headlineLabel.text = article.title
            publishedDateLabel.text = date.publishDate(dateString: article.publishedDate!)
            publishedDateLabel.textColor = UIColor.secondaryLabel
            isRead = article.isRead
            if let urlString = article.imageURL, !urlString.isEmpty {
                thumbnailView.downloadImage(url: URL(string: urlString)!)
                thumbnailView.contentMode = .scaleToFill
            } else {
                thumbnailView.image = UIImage(systemName: "photo")
                thumbnailView.tintColor = .lightGray
            }
        }
    }
}
