import UIKit
import Alamofire

class StoryCell: UITableViewCell {

    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var headlineLabel: UILabel!
    
    var isRead: Bool = false {
        didSet {
            headlineLabel.textColor = isRead ? .lightGray : .label
        }
    }
    
    var story: Story? {
        didSet {
            guard let story = story else { return }
            headlineLabel?.text = story.title
            isRead = story.isRead ?? false
            
            let multimedia = story.multimedia
            if multimedia.count >= 3 {
                let thumbnailString = multimedia[2].url
                let urlString = URL(string: thumbnailString)
                thumbnailView.downloadImage(url: urlString!)
                thumbnailView.contentMode = .scaleToFill
            }
        }
    }
    
    var topStory: TopStory? {
        didSet {
            guard let topStory = topStory else { return }
            headlineLabel.text = topStory.title
            isRead = topStory.isRead
            if let urlString = URL(string: topStory.imageURL!) {
                thumbnailView.downloadImage(url: urlString)
                thumbnailView.contentMode = .scaleToFill
            }
        }
    }
}
