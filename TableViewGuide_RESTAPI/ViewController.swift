import UIKit
import Kingfisher

class ViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var stories: [Story] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Top Stories"
        tableView.dataSource = self

        Story.fetchStories(successCallback: { (stories: [Story]) -> Void in
            DispatchQueue.main.async {
                self.stories = stories
                self.tableView.reloadData()
            }
        }, error: nil)
    }
    
    private func downloadImage(imageView: UIImageView, url: URL) {
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: url,
                              placeholder: UIImage(named: "placeholderImage"),
                              options: [
                                .processor(DownsamplingImageProcessor(size: imageView.bounds.size)),
                                .scaleFactor(UIScreen.main.scale),
                                .cacheOriginalImage,
                                .transition(.fade(0.25))
                              ])
        {
            result in
            switch result {
            case .success(let value):
                imageView.image = value.image
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoryCell") as! StoryCell
        cell.story = stories[indexPath.row]
        var urlImage: [String] = []
        for story in stories {
            urlImage.append(story.thumbnailUrl!)
        }
        if let urlString = URL(string: urlImage[indexPath.row]) {
            downloadImage(imageView: cell.thumbnailView, url: urlString)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
}
