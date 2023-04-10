import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private var activityIndicatorView = UIActivityIndicatorView()
    var fetchResultsController: NSFetchedResultsController<TopStories>!
    private let animationDuration: TimeInterval = 1
    private let heightForRow: CGFloat = 100
    var stories: [Story] = []
    
    enum Titles {
        static let internetError = "No Internet"
    }
    
    enum Message {
        static let checkNetwork = "Checking the network cables, modem, and router."
    }
    
    private func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default)
        alert.addAction(ok)
        present(alert, animated: true)
    }
    
    // MARK: - LifeCycle ViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Top Stories"
        setupTableView()
        initfetchResultsController()
        fetchResultsController.delegate = self
        activityIndicatorView.startAnimating()
        fetchTopStories()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = heightForRow
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(onRefesh), for: .valueChanged)
    }
    
    // Fetch Data
    private func fetchTopStories() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            Articles.fetchStory(successCallBack: { (stories: [Story]) -> Void in
                DispatchQueue.main.async {
                    UIView.animate(withDuration: .nan) {
                        self.deleteAllData()
                        self.tableView.reloadData()
                    } completion: { _ in
                        self.stories = stories
                        self.saveTopStories(stories: stories)
                        UIView.transition(with: self.tableView, duration: self.animationDuration, options: .transitionCrossDissolve, animations: { self.tableView.reloadData()
                        })
                    }
                }
            }, requestError: { (error: (URLSession.CustomError)?) -> Void in
                self.handlerError(error: error)
                self.activityIndicatorView.stopAnimating()
            })
        }
    }
    
    // MARK: - Layout SubView
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupIndicationView()
        
        let reloadButton = UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"), style: .plain, target: self, action: #selector(handlerReload))
        navigationItem.rightBarButtonItems = [reloadButton]
    }
    
    private func setupIndicationView() {
        activityIndicatorView.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
        activityIndicatorView.center = CGPoint(x: (UIScreen.main.bounds.width) / 2, y: 120)
        activityIndicatorView.hidesWhenStopped = true
        view.addSubview(activityIndicatorView)
    }
    
    // Handler reload button refesh right BarButtonItem
    @objc private func handlerReload() {
        if !self.stories.isEmpty {
            self.stories.removeAll()
            self.deleteAllData()
            self.tableView.reloadData()
        }
        self.activityIndicatorView.startAnimating()
        Articles.fetchStory(successCallBack: { (stories: [Story]) -> Void in
            DispatchQueue.main.async {
                self.stories = stories
                self.saveTopStories(stories: stories)
                UIView.transition(with: self.tableView, duration: self.animationDuration, options: .transitionCrossDissolve) {
                    self.activityIndicatorView.stopAnimating()
                    self.tableView.reloadData()
                }
            }
        }, requestError: { (error: (URLSession.CustomError)?) -> Void in
            self.handlerError(error: error)
        })
    }
    
    // Handler refeshController in tableView
    @objc private func onRefesh() {
        DispatchQueue.global().asyncAfter(deadline: .now() + animationDuration) {
            Articles.fetchStory(successCallBack: { (stories: [Story]) -> Void in
                DispatchQueue.main.async {
                    self.stories = stories
                    self.saveTopStories(stories: stories)
                    self.tableView.reloadData()
                }
            }, requestError: {_ in
                DispatchQueue.main.async {
                    self.alert(title: Titles.internetError, message: Message.checkNetwork)
                }
            })
        }
        self.tableView.refreshControl?.endRefreshing()
    }
}
    
// MARK: - TableView DataSource and Delegate
    
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoryCell") as! StoryCell
        if fetchResultsController.fetchedObjects!.count > 0 {
            let storyAtIndex = fetchResultsController.object(at: indexPath)
            cell.topStories = storyAtIndex
            self.activityIndicatorView.stopAnimating()
            return cell
        } else {
            let story = stories[indexPath.row]
            cell.story = story
            self.activityIndicatorView.stopAnimating()
            return cell
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if fetchResultsController.fetchedObjects!.count > 0 {
            return fetchResultsController.fetchedObjects!.count
        } else {
            return stories.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vcDetails = storyboard?.instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
        if !stories.isEmpty {
            vcDetails.stories = stories[indexPath.row]
            vcDetails.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vcDetails, animated: true)
        }
    }
}

// MARK: - Fetch results controller

extension ViewController: NSFetchedResultsControllerDelegate {
    private func initfetchResultsController() {
        guard let context = AppDelegate.managedObjectContext else { return }
        let fetchRequest = TopStories.fetchRequest()
        fetchRequest.sortDescriptors = []
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                            managedObjectContext: context,
                                                            sectionNameKeyPath: nil,
                                                            cacheName: nil)
        do {
            try fetchResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func saveTopStories(stories: [Story]) {
        self.deleteAllData()
        for value in stories {
            insertTopStories(title: value.title, imageURL: value.multimedia[2].url)
        }
        print("Number TopStories saved: \(fetchResultsController.fetchedObjects?.count ?? 0)")
    }
    
    private func insertTopStories(title: String, imageURL: String) {
        guard let context = AppDelegate.managedObjectContext else { return }
        let insertNewObject = NSEntityDescription.insertNewObject(forEntityName: "TopStories", into: context) as! TopStories
        insertNewObject.titles = title
        insertNewObject.imagesURL = imageURL
        do {
            try context.save()
            try fetchResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func deleteAllData() {
        guard let context = AppDelegate.managedObjectContext else { return }
        let fetchRequestResult = NSFetchRequest<NSFetchRequestResult>(entityName: "TopStories")
        let batchDelete = NSBatchDeleteRequest(fetchRequest: fetchRequestResult)
        do {
            try context.execute(batchDelete)
            try context.save()
            try fetchResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func handlerError(error: (URLSession.CustomError)?) {
        switch error {
        case .inconnectInternet:
            DispatchQueue.main.async {
                self.alert(title: Titles.internetError, message: Message.checkNetwork)
            }
            break
        case .badStutusCode:
            print("Error: Bad statusCode")
            break
        case .invalidResponse:
            print("Error: Invalid Response")
            break
        case .invalidURL:
            print("Error: Invalid URL")
            break
        case .invalidData:
            print("Error: Invalid Data")
            break
        case .none:
            print("No handler")
        }
    }
}
