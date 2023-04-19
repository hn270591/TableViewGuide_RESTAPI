import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private var activityIndicatorView = UIActivityIndicatorView()
    var fetchResultsController: NSFetchedResultsController<TopStory>!
    var fetchSelectedStory: NSFetchedResultsController<SelectedStory>!
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
        initFetchSelectedStory()
        fetchSelectedStory.delegate = self
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
            BaseReponse.shared.storyResponse(completion: { stories, error  in
                if let error = error {
                    if error == .inConnect {
                        DispatchQueue.main.async {
                            self.alert(title: Titles.internetError, message: Message.checkNetwork)
                        }
                    } else {
                        print(error)
                    }
                    return
                }
                UIView.animate(withDuration: .nan) {
                    self.deleteAllStory()
                    self.tableView.reloadData()
                } completion: { _ in
                    self.stories = stories
                    self.saveStory(stories: stories)
                    UIView.transition(with: self.tableView, duration: self.animationDuration, options: .transitionCrossDissolve, animations: { self.tableView.reloadData()
                    })
                }
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
            self.deleteAllStory()
            self.tableView.reloadData()
        }
        self.activityIndicatorView.startAnimating()
        BaseReponse.shared.storyResponse(completion: { stories, error  in
            if let error = error {
                if error == .inConnect {
                    DispatchQueue.main.async {
                        self.alert(title: Titles.internetError, message: Message.checkNetwork)
                    }
                } else {
                    print(error)
                }
                return
            }
            self.stories = stories
            self.saveStory(stories: stories)
            UIView.transition(with: self.tableView, duration: self.animationDuration, options: .transitionCrossDissolve) {
                self.activityIndicatorView.stopAnimating()
                self.tableView.reloadData()
            }
        })
    }
    
    // Handler refeshController in tableView
    @objc private func onRefesh() {
        BaseReponse.shared.storyResponse(completion: { stories, error  in
            if let error = error {
                if error == .inConnect {
                    self.alert(title: Titles.internetError, message: Message.checkNetwork)
                } else {
                    print(error)
                }
                return
            }
            self.stories = stories
            self.saveStory(stories: stories)
            self.tableView.reloadData()
        })
        self.tableView.refreshControl?.endRefreshing()
    }
}
    
// MARK: - TableView DataSource and Delegate
    
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoryCell") as! StoryCell
        cell.delegate = self
        if fetchResultsController.fetchedObjects!.count > 0 {
            let storyAtIndex = fetchResultsController.object(at: indexPath)
            cell.topStory = storyAtIndex
            let count = fetchSelectedStory.fetchedObjects?.count ?? 0
            if count > 0 {
                let stories = fetchSelectedStory.fetchedObjects!
                let titles = stories.compactMap({ $0.title })
                if titles.firstIndex(of: storyAtIndex.title!) != nil {
                    cell.headlineLabel.textColor = .darkGray
                }
            }
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
            vcDetails.story = stories[indexPath.row]
            vcDetails.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vcDetails, animated: true)
        }
    }
}

// MARK: - Fetch results controller

extension ViewController: NSFetchedResultsControllerDelegate {
    private func initfetchResultsController() {
        guard let context = AppDelegate.managedObjectContext else { return }
        let fetchRequest = TopStory.fetchRequest()
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
    
    private func saveStory(stories: [Story]) {
        self.deleteAllStory()
        for value in stories {
            insertStory(title: value.title, imageURL: value.multimedia[2].url)
        }
        print("Number TopStory saved: \(fetchResultsController.fetchedObjects?.count ?? 0)")
    }
    
    private func insertStory(title: String, imageURL: String) {
        guard let context = AppDelegate.managedObjectContext else { return }
        let insertNewObject = NSEntityDescription.insertNewObject(forEntityName: "TopStory", into: context) as! TopStory
        insertNewObject.title = title
        insertNewObject.imagesURL = imageURL
        do {
            try context.save()
            try fetchResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func deleteAllStory() {
        guard let context = AppDelegate.managedObjectContext else { return }
        let fetchRequestResult = NSFetchRequest<NSFetchRequestResult>(entityName: "TopStory")
        let batchDelete = NSBatchDeleteRequest(fetchRequest: fetchRequestResult)
        do {
            try context.execute(batchDelete)
            try context.save()
            try fetchResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func initFetchSelectedStory() {
        guard let context = AppDelegate.managedObjectContext else { return }
        let fetchRequest = SelectedStory.fetchRequest()
        fetchRequest.sortDescriptors = []
        fetchSelectedStory = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                            managedObjectContext: context,
                                                            sectionNameKeyPath: nil,
                                                            cacheName: nil)
        do {
            try fetchSelectedStory.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func saveSelectedStory(title: String) {
        guard let context = AppDelegate.managedObjectContext else { return }
        let insertNewObject = NSEntityDescription.insertNewObject(forEntityName: "SelectedStory", into: context) as! SelectedStory
        insertNewObject.title = title
        do {
            try context.save()
            try fetchSelectedStory.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: - Headline Blurred Delegate

extension ViewController: HeadlineBlurredDelegate {
    func headlineBlurred(_ cell: StoryCell) {
        if let titleAtIndex = cell.topStory?.title {
            let count = fetchSelectedStory.fetchedObjects?.count ?? 0
            if count > 0 {
                let stories = fetchSelectedStory.fetchedObjects!
                let titles = stories.compactMap({ $0.title })
                if titles.firstIndex(of: titleAtIndex) != nil {
                    return
                } else {
                    saveSelectedStory(title: titleAtIndex)
                    print("A new story has been read")
                }
            } else {
                saveSelectedStory(title: titleAtIndex)
                print("A new story has been read")
            }
        }
    }
}
