import UIKit

class StoryCell: UITableViewCell {

    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var headlineLabel: UILabel!

    var story: Story? {
        didSet {
            headlineLabel?.text = story?.headline
            headlineLabel?.sizeToFit()
        }
    }
}

