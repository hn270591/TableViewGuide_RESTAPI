
import UIKit
import CoreData
import WebKit

class DetailsViewController: UIViewController, WKNavigationDelegate {

    // MARK: - Properties
    
    var story: Story?
    var article: ArticleItem?
    var bookmarkStory: BookmarkStory!
    private var webView: WKWebView!
    private var toolBar = UIToolbar()
    private var activityIndicator: UIActivityIndicatorView!
    private var fetchResultsController: NSFetchedResultsController<BookmarkStory>!
    
    private let bookmarkButton = UIBarButtonItem(image: UIImage(systemName: "star"),
                                                 style: .done, target: .none,
                                                 action: #selector(onBookmark))
    private let backButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                                 style: .done, target: .none,
                                                 action: #selector(backAction))
    private let backAllButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"),
                                                    style: .done, target: .none,
                                                    action: #selector(backAllAction))
    private let forwardButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.right"),
                                                    style: .plain, target: .none,
                                                    action: #selector(forwardAction))
    private let refreshButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh,
                                                        target: .none,
                                                        action: #selector(refreshAction))
    
    private var isbookmark = false {
        didSet {
            bookmarkButton.image = isbookmark ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        }
    }
    
    // Load View
    override func loadView() {
        super.loadView()
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.frame = CGRect(x: 60, y: -7, width: 64, height: 64)
        activityIndicator.tintColor = .black
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        webView.addSubview(activityIndicator)
    }
    
    // Life cycle View
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        fetchBookmarkStory()
    }
    
    private func resultsUrlString() -> String {
        var urlString: String!
        let countOfStoriesURL = story?.url.count ?? 0
        let countOfArticlesURL = article?.web_url.count ?? 0
        
        if countOfStoriesURL != 0 {
            urlString = story!.url
            title = story!.title
        } else if countOfArticlesURL != 0 {
            urlString = article!.web_url
            title = article!.headline.main
        } else {
            urlString = bookmarkStory.url_web
            title = bookmarkStory.title
        }
        return urlString
    }
    
    // Setup WebView
    private func setupWebView() {
        webView.navigationDelegate = self
        let urlString = resultsUrlString()
        let urlRequest = URLRequest(url: URL(string: urlString)!)
        webView.load(urlRequest)
        webView.allowsBackForwardNavigationGestures = true
    }
    
    // Fetch Bookmark Story filted
    private func fetchBookmarkStory() {
        let urlString = resultsUrlString()
        fetchFilterBookmartStories(urlFilter: urlString)
        let count = fetchResultsController.fetchedObjects?.count ?? 0
        if count > 0 {
            isbookmark = true
        } else {
            isbookmark = false
        }
    }
    
    // Layout SubView
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupNavigationViewAndToolBar()
    }
    
    private func setupNavigationViewAndToolBar() {
        backButtonItem.isEnabled = false
        forwardButtonItem.isEnabled = false
        
        backAllButtonItem.target = self
        bookmarkButton.target = self
        navigationItem.leftBarButtonItems = [ backAllButtonItem]
        navigationItem.rightBarButtonItems = [ bookmarkButton ]
        
        view.addSubview(toolBar)
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        toolBar.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        toolBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        toolBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        toolBar.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        let flexibleSpace = UIBarButtonItem(systemItem: .flexibleSpace)
        let fixedSpace = UIBarButtonItem(systemItem: .fixedSpace)
        fixedSpace.width = 50
        
        toolBar.items = [ backButtonItem, fixedSpace, forwardButtonItem, flexibleSpace, refreshButtonItem]
        }
    
    @objc private func refreshAction() {
        webView.reload()
    }
    
    // Setup Bookmark
    @objc private func onBookmark() {
        isbookmark.toggle()
        let countOfStoriesURL = self.story?.url.count ?? 0
        let countOfArticlesURL = self.article?.web_url.count ?? 0
        if isbookmark {
            // insert stories
            if countOfStoriesURL != 0 {
                insertStory(title: self.story!.title,
                            url_web: self.story!.url,
                            imageURL: self.story!.multimedia[2].url)
            } else if countOfArticlesURL != 0 {
                insertStory(title: self.article!.headline.main,
                            url_web: self.article!.web_url,
                            imageURL: "https://static01.nyt.com/" + self.article!.multimedia[19].url)
            } else {
                return
            }
        } else {
            // delete stories
            let urlString = resultsUrlString()
            fetchFilterBookmartStories(urlFilter: urlString)
            let deleteStories = fetchResultsController.object(at: IndexPath(item: 0, section: 0))
            guard let context = AppDelegate.managedObjectContext else { return }
            context.delete(deleteStories)
            do {
                try context.save()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    @objc private func backAction() {
        guard webView.canGoBack else { return }
        webView.goBack()
    }
    
    @objc private func forwardAction() {
        guard webView.canGoForward else { return }
        webView.goForward()
    }
    
    @objc private func backAllAction() {
        navigationController?.popViewController(animated: true)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
        activityIndicator.stopAnimating()
        backButtonItem.isEnabled = webView.canGoBack
        forwardButtonItem.isEnabled = webView.canGoForward
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension DetailsViewController: NSFetchedResultsControllerDelegate {
    private func fetchFilterBookmartStories(urlFilter: String) {
        guard let context = AppDelegate.managedObjectContext else { return }
        let fetchRequest = BookmarkStory.fetchRequest()
        let predicate = NSPredicate(format: "url_web == %@", urlFilter)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = []
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchResultsController.performFetch()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private func insertStory(title: String, url_web: String, imageURL: String) {
        guard let context = AppDelegate.managedObjectContext else { return }
        let insertTitlesStories = NSEntityDescription.insertNewObject(forEntityName: "BookmarkStory", into: context) as! BookmarkStory
        insertTitlesStories.title = title
        insertTitlesStories.url_web = url_web
        insertTitlesStories.imageURL = imageURL
        do {
            try context.save()
            try fetchResultsController.performFetch()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
