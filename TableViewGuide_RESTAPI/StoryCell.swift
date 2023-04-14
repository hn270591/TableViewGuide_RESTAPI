import UIKit
import Alamofire
import AlamofireImage

class StoryCell: UITableViewCell {

    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var headlineLabel: UILabel!
    
    var story: Story? {
        didSet {
            headlineLabel?.text = story?.title
            headlineLabel?.sizeToFit()
            
            guard let multimedia = story?.multimedia else { return }
            if multimedia.count >= 3 {
                let thumbnailString = multimedia[2].url
                let urlString = URL(string: thumbnailString)
                thumbnailView.downloadImage(url: urlString!)
                thumbnailView.sizeToFit()
                thumbnailView.contentMode = .scaleToFill
            }
        }
    }
    
    var topStory: TopStory? {
        didSet {
            headlineLabel.text = topStory?.title
            if let urlString = URL(string: topStory?.imagesURL ?? "") {
                thumbnailView.downloadImage(url: urlString)
                thumbnailView.contentMode = .scaleToFill
            }
        }
    }
}
