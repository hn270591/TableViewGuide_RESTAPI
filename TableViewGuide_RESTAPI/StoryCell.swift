import UIKit

class StoryCell: UITableViewCell {

    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var headlineLabel: UILabel!

    var story: Story? {
        didSet {
            headlineLabel?.text = story?.headline
            headlineLabel?.sizeToFit()
            
            guard let urlString = URL(string: (story?.thumbnailUrl)!) else { return }
            thumbnailView.downloadImageView(url: urlString, error: nil)
            thumbnailView.sizeToFit()
        }
    }
}

// MARK: - Extension UIImageView

extension UIImageView {
    func downloadImageView(url: URL, error: ((Error?) -> Void)?) {
        URLSession.shared.dataTask(with: url) { data, response, requestError in
            if let requestError = requestError {
                error?(requestError)
            } else {
                if let data = data {
                    let image = UIImage(data: data)
                    DispatchQueue.main.async {
                        self.image = image
                    }
                } else {
                    error?(nil)
                }
            }
        }.resume()
    }
}
