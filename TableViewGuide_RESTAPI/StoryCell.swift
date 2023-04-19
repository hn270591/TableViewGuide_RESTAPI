import UIKit
import Alamofire

protocol HeadlineBlurredDelegate: AnyObject {
    func headlineBlurred(_ cell: StoryCell)
}

class StoryCell: UITableViewCell {

    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var headlineLabel: UILabel!
    
    weak var delegate: HeadlineBlurredDelegate!
    var isSelectedStory: Bool = false {
        didSet {
            headlineLabel.textColor = isSelectedStory ? .darkGray : .label
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected == true {
            isSelectedStory = true
            delegate?.headlineBlurred(self)
        }
    }
    
    var story: Story? {
        didSet {
            headlineLabel?.text = story?.title
            headlineLabel?.sizeToFit()
            headlineLabel.textColor = .label
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
            isSelectedStory = topStory!.isSelected
            if let urlString = URL(string: topStory?.imagesURL ?? "") {
                thumbnailView.downloadImage(url: urlString)
                thumbnailView.contentMode = .scaleToFill
            }
        }
    }
}
