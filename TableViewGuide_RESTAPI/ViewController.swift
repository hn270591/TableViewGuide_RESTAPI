import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    private let animationDuration: TimeInterval = 1
    var stories: [Story] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Top Stories"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(onRefesh), for: .valueChanged)
        Articles.fetchStory(successCallBack: { (stories: [Story]) -> Void in
            DispatchQueue.main.async {
                self.stories = stories
                UIView.transition(with: self.tableView, duration: self.animationDuration,options: .transitionCrossDissolve, animations: { self.tableView.reloadData()
                })
            }
        })
    }
    
    @objc private func onRefesh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            Articles.fetchStory(successCallBack: { (stories: [Story]) -> Void in
                DispatchQueue.main.async {
                    self.stories = stories
                    self.tableView.reloadData()
                }
            })
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoryCell") as! StoryCell
        cell.story = stories[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vcDetails = storyboard?.instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
        vcDetails.stories = stories[indexPath.row]
        vcDetails.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vcDetails, animated: true)
    }
}
