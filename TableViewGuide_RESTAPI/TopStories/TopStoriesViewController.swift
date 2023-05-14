import UIKit
import CoreData

class TopStoriesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let animationDuration: TimeInterval = 1
    private let heightForRow: CGFloat = 100
    var selectedIndex: Int?
    var stories: [Story] = []
    private lazy var categoryButton: UIBarButtonItem! = nil
    private var userDefaults = UserDefaults.standard
    private var currentCategory = "Home"
    
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        indicatorView.center = view.center
        view.addSubview(indicatorView)
        return indicatorView
    }()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate!.persistenContainer
    }()
    
    private lazy var articleResultsController: NSFetchedResultsController<Article> = {
        let fetchRequest = Article.fetchRequest()
        fetchRequest.sortDescriptors = []
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: persistentContainer.viewContext,
                                                              sectionNameKeyPath: nil,cacheName: nil)
        controller.delegate = self
        do {
            try controller.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        return controller
    }()
    
    private lazy var readArticleResultsController: NSFetchedResultsController<ReadArticle> = {
        let fetchRequest = ReadArticle.fetchRequest()
        fetchRequest.sortDescriptors = []
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: persistentContainer.viewContext,
                                                    sectionNameKeyPath: nil,cacheName: nil)
        controller.delegate = self
        do {
            try controller.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        return controller
    }()
    
    enum Titles {
        static let internetError = "No Internet"
    }
    
    enum Message {
        static let checkNetwork = "Checking the network cables, modem, and router."
    }
    
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default)
        alert.addAction(ok)
        present(alert, animated: true)
    }
    
    // MARK: - LifeCycle ViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Top Stories"
        navigationController?.navigationBar.prefersLargeTitles = true
        setupNavigationItem()
        setupTableView()
        fetchTopStories()
        
        // Notification when changed font size
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(updateUI), name: FontUpdateNotification, object: nil)
    }
    
    @objc func updateUI() {
        tableView.reloadData()
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = heightForRow
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(onRefesh), for: .valueChanged)
    }
    
    func setupNavigationItem() {
        categoryButton = UIBarButtonItem(title: currentCategory, style: .done, target: self, action: #selector(handleCategory))
        categoryButton.tintColor = .systemGray2
        navigationItem.rightBarButtonItems = [categoryButton]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        // Lighten headline when clear ReadArticle
        try? readArticleResultsController.performFetch()
        let readArticle = readArticleResultsController.fetchedObjects ?? []
        if readArticle.isEmpty {
            for index in 0..<stories.count {
                if stories[index].isRead == true {
                    stories[index].isRead = false
                    let indexPath = IndexPath(row: index, section: 0)
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
        
        // Blurred headline when come back from vcDetails
        if let index = selectedIndex {
            let indexPath = IndexPath(row: index, section: 0)
            stories[index].isRead = true
            self.tableView.reloadRows(at: [indexPath], with: .none)
            //Reset
            selectedIndex = nil
        }
    }
        
    // Handle Error
    func handleError(_ error: BaseResponseError) {
        if error == .inConnect {
            DispatchQueue.main.async {
                self.alert(title: Titles.internetError, message: Message.checkNetwork)
            }
        } else {
            print(error)
        }
        return
    }
    
    func handleDataLoaded(_ stories: [Story]) {
        self.stories = self.checkRead(stories)
        self.setCache(stories: self.stories)
        self.tableView.reloadData()
    }
    
    // Fetch Data
    func fetchTopStories() {
        let category = currentCategory.lowercased()
        if articleResultsController.fetchedObjects?.isEmpty == true, stories.isEmpty {
            self.activityIndicatorView.startAnimating()
        }
        NYTimeClient.shared.getTopStories(sectionValue: category, completion: { stories, error  in
            self.activityIndicatorView.stopAnimating()
            if let error = error {
                self.handleError(error)
            } else {
                self.handleDataLoaded(stories)
            }
        })
    }
    
    // Check Read Article
    func checkRead(_ stories: [Story]) -> [Story] {
        let readArticles = readArticleResultsController.fetchedObjects ?? []
        if readArticles.isEmpty {
            return stories
        }
        var mutable = Array(stories)
        let readArticleURLs = readArticles.compactMap({ $0.url })
        for index in 0..<mutable.count {
            if readArticleURLs.contains(mutable[index].url) {
                mutable[index].isRead = true
            }
        }
        return mutable
    }
    
    // Set cache Article
    func setCache(stories: [Story] ) {
        if currentCategory == "Home" {
            self.clearArticles()
            for story in stories {
                insertStory(title: story.title, imageURL: story.multimedia?[2].url ?? "", url: story.url, isRead: story.isRead ?? false, publishedDate: story.published_date)
            }
            try? articleResultsController.performFetch()
            print("Number TopStoris saved: \(articleResultsController.fetchedObjects?.count ?? 0)")
        }
    }
    
    // Handler refeshController in tableView
    @objc func onRefesh() {
        let category = currentCategory.lowercased()
        NYTimeClient.shared.getTopStories(sectionValue: category , completion: { stories, error  in
            if let error = error {
                self.handleError(error)
            } else {
                self.handleDataLoaded(stories)
            }
        })
        self.tableView.refreshControl?.endRefreshing()
    }
    
    // Handler filter category
    @objc func handleCategory() {
        let vcCategory = CategoriesViewController()
        vcCategory.delegate = self
        navigationController?.pushViewController(vcCategory, animated: true)
    }
}
    
// MARK: - TableView DataSource and Delegate
    
extension TopStoriesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoryCell") as! StoryCell
        if stories.count > 0 {
            let story = stories[indexPath.row]
            cell.story = story
        } else {
            let story = articleResultsController.object(at: indexPath)
            cell.article = story
        }
        
        // Notification when changed font size
        let notification = NotificationCenter.default
        notification.addObserver(forName: FontUpdateNotification, object: nil, queue: .main) { _ in
            cell.configureUI()
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count > 0 ? stories.count : articleResultsController.fetchedObjects!.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vcDetails = DetailsViewController()
        if !stories.isEmpty {
            vcDetails.story = stories[indexPath.row]
            vcDetails.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vcDetails, animated: true)
            selectedIndex = indexPath.row
        }
    }
}

// MARK: - CategoryValueDelegate

extension TopStoriesViewController: CategoriesViewControllerDelegate {
    func setCategoryValue(_ sender: CategoriesViewController, category: String) {
        categoryButton.title = category
        currentCategory = category.lowercased()
        
        // Save Category
        userDefaults.setCategory(value: category)
        
        // Reload TopStories
        onRefesh()
    }
}

// MARK: - Fetch results controller

extension TopStoriesViewController: NSFetchedResultsControllerDelegate {
    func insertStory(title: String, imageURL: String, url: String, isRead: Bool, publishedDate: String) {
        let context = persistentContainer.viewContext
        let newArticle = Article(context: context)
        newArticle.title = title
        newArticle.imageURL = imageURL
        newArticle.url = url
        newArticle.isRead = isRead
        newArticle.publishedDate = publishedDate
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func clearArticles() {
        let context = persistentContainer.viewContext
        let fetchRequestResult = NSFetchRequest<NSFetchRequestResult>(entityName: "Article")
        let batchDelete = NSBatchDeleteRequest(fetchRequest: fetchRequestResult)
        do {
            try context.execute(batchDelete)
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}
