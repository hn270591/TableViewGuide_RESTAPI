import UIKit

class ViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!

    var stories: [Story] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self

        Story.fetchStories(successCallback: { (stories: [Story]) -> Void in
            DispatchQueue.main.async {
                self.stories = stories
                self.tableView.reloadData()
            }
        }, error: nil)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoryCell") as! StoryCell
        cell.story = stories[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
}
