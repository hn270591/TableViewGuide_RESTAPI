import UIKit
import CoreData
import WebKit

class DetailsViewController: UIViewController, WKNavigationDelegate {

    // MARK: - Properties
    
    var story: Story?
    var article: ArticleItem?
    var bookmarkedArticle: BookmarkedArticle?
    private var webView: WKWebView!
    private var toolBar = UIToolbar()
    private var activityIndicatorView: UIActivityIndicatorView!
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate!.persistenContainer
    }()
    
    private lazy var bookmarkedResultsController: NSFetchedResultsController<BookmarkedArticle> = {
        let fetchRequest = BookmarkedArticle.fetchRequest()
        fetchRequest.sortDescriptors = []
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: persistentContainer.viewContext,
                                                    sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        do {
            try controller.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        return controller
    }()
    
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
        activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.frame = CGRect(x: 60, y: -7, width: 64, height: 64)
        activityIndicatorView.tintColor = .black
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimating()
        webView.addSubview(activityIndicatorView)
    }
    
    // Life cycle View
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        saveReadArticle()
        checkBookmark()
    }
        
    func saveReadArticle() {
        guard let story = story else { return }
        saveReadArticle(title: story.title, url: story.url, imageURL: story.multimedia[2].url, createdDate: Date())
    }
    
    func saveReadArticle(title: String, url: String, imageURL: String, createdDate: Date) {
        let context = persistentContainer.viewContext
        let newArticle = ReadArticle(context: context)
        newArticle.title = title
        newArticle.url = url
        newArticle.imageURL = imageURL
        newArticle.createdDate = createdDate
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func resultsUrlString() -> String {
        var urlString: String!
        let storyURL = story?.url ?? ""
        let articleURL = article?.web_url ?? ""
        if !storyURL.isEmpty {
            urlString = story!.url
            title = story!.title
        } else if !articleURL.isEmpty {
            urlString = article!.web_url
            title = article!.headline.main
        } else {
            urlString = bookmarkedArticle?.url_web
            title = bookmarkedArticle?.title
        }
        return urlString
    }
    
    // Setup WebView
    func setupWebView() {
        webView.navigationDelegate = self
        let urlString = resultsUrlString()
        let urlRequest = URLRequest(url: URL(string: urlString)!)
        webView.load(urlRequest)
        webView.allowsBackForwardNavigationGestures = true
    }
    
    func filterURL_web(urlString: String) {
        let predicate = NSPredicate(format: "url_web == %@", urlString)
        bookmarkedResultsController.fetchRequest.predicate = predicate
        try? bookmarkedResultsController.performFetch()
    }
    
    // check bookmarked
    func checkBookmark() {
        let urlString = resultsUrlString()
        filterURL_web(urlString: urlString)
        let count = bookmarkedResultsController.fetchedObjects?.count ?? 0
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
    
    func setupNavigationViewAndToolBar() {
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
    
    @objc func refreshAction() {
        webView.reload()
    }
    
    // Insert stories when isbookmark = true
    func handleOnBookmark(storyURL: String, articleURL: String) {
        if !storyURL.isEmpty {
            guard let story = self.story else { return }
            insertArticle(title: story.title,
                          url_web: story.url,
                          imageURL: story.multimedia[2].url)
        } else if !articleURL.isEmpty {
            guard let article = self.article else { return }
            insertArticle(title: article.headline.main,
                          url_web: article.web_url,
                          imageURL: "https://static01.nyt.com/" + (article.multimedia[19].url))
        } else { return }
    }
    
    //  Delete stories when isbookmark = false
    func handleFalseBookmark(storyURL: String, articleURL: String) {
        let urlString = resultsUrlString()
        filterURL_web(urlString: urlString)
        let deleteArticle = bookmarkedResultsController.object(at: IndexPath(item: 0, section: 0))
        let context = persistentContainer.viewContext
        context.delete(deleteArticle)
        do {
            try context.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    // Setup Bookmark
    @objc func onBookmark() {
        isbookmark.toggle()
        let storyURL = story?.url ?? ""
        let articleURL = article?.web_url ?? ""
        if isbookmark {
            // insert stories
            handleOnBookmark(storyURL: storyURL, articleURL: articleURL)
        } else {
            // delete stories
           handleFalseBookmark(storyURL: storyURL, articleURL: articleURL)
        }
    }
    
    @objc func backAction() {
        guard webView.canGoBack else { return }
        webView.goBack()
    }
    
    @objc func forwardAction() {
        guard webView.canGoForward else { return }
        webView.goForward()
    }
    
    @objc func backAllAction() {
        navigationController?.popViewController(animated: true)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicatorView.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
        activityIndicatorView.stopAnimating()
        backButtonItem.isEnabled = webView.canGoBack
        forwardButtonItem.isEnabled = webView.canGoForward
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension DetailsViewController: NSFetchedResultsControllerDelegate {
    func insertArticle(title: String, url_web: String, imageURL: String) {
        let context = persistentContainer.viewContext
        let insertNewObject = BookmarkedArticle(context: context)
        insertNewObject.title = title
        insertNewObject.url_web = url_web
        insertNewObject.imageURL = imageURL
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}

