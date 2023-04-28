import UIKit
import Alamofire

class StoryCell: UITableViewCell {

    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    private var postArticleTime = Date()
    var isRead: Bool = false {
        didSet {
            headlineLabel.textColor = isRead ? .lightGray : .label
        }
    }
    
    var story: Story? {
        didSet {
            guard let story = story else { return }
            headlineLabel?.text = story.title
            dateLabel.text = postArticleTime.previousTime(date: story.published_date)
            dateLabel.textColor = UIColor.secondaryLabel
            isRead = story.isRead ?? false
            
            let multimedia = story.multimedia
            if !multimedia.isEmpty {
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
            dateLabel.text = postArticleTime.previousTime(date: article.published_date!)
            dateLabel.textColor = UIColor.secondaryLabel
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

extension Date {
    func previousTime(date: String) -> String {
        // ISO 8601 format
        let myDateFormatter = ISO8601DateFormatter()
        guard let monthOfAllDate = myDateFormatter.date(from: date) else { return "" }
        // Create timeInterval before
        let secondsAgo = Int(Date().timeIntervalSince(monthOfAllDate))
        
        var value: Int?
        var unti: String?
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        let year = 12 * month
        
        switch secondsAgo {
        case 0:
            unti = "now"
        case 0..<minute:
            value = secondsAgo
            unti = "seconds"
        case minute..<hour:
            value = secondsAgo / minute
            unti = "minutes"
        case hour..<day:
            value = secondsAgo / hour
            unti = "hours"
        case day..<week:
            value = secondsAgo / day
            unti = "days"
        case week..<month:
            value = secondsAgo / week
            unti = "weeks"
        case month..<year:
            value = secondsAgo / month
            unti = "months"
        default:
            value = secondsAgo / year
            unti = "years"
        }
        let dateString = "\(value ?? 0) \(unti ?? "") ago"
        return dateString
    }
}
