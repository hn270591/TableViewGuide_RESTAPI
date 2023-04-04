import UIKit
import Kingfisher

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
    
    var topStories: TopStories? {
        didSet {
            headlineLabel.text = topStories?.titles
            if let urlString = URL(string: topStories?.imagesURL ?? "") {
                thumbnailView.downloadImage(url: urlString)
                thumbnailView.contentMode = .scaleToFill
            }
        }
    }
}

// MARK: - Extension ImageView

extension UIImageView {
    func downloadImage(url: URL) {
        self.kf.indicatorType = .activity
        self.kf.setImage(with: url,
                              placeholder: UIImage(named: "placeholderImage"),
                              options: [
                                .processor(DownsamplingImageProcessor(size: self.bounds.size)),
                                .scaleFactor(UIScreen.main.scale),
                                .cacheOriginalImage,
                                .transition(.fade(0.25))
                              ])
        {
            result in
            switch result {
            case .success(let value):
                self.image = value.image
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}
