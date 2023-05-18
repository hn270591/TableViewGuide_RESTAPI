
import UIKit
import WebKit
import CoreData

class DetailsViewController: UIViewController, WKNavigationDelegate {
    
    // MARK: - Properties
    
    var story: Story?
    var article: ArticleItem?
    var bookmarkedArticle: BookmarkedArticle?
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.navigationDelegate = self
        return webView
    }()
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.tintColor = .black
        activityIndicatorView.startAnimating()
        webView.addSubview(activityIndicatorView)
        return activityIndicatorView
    }()
    
    private lazy var backAllButtonItem: UIBarButtonItem! = nil
    private lazy var bookmarkButton: UIBarButtonItem! = nil
    private lazy var backButtonItem: UIBarButtonItem! = nil
    private lazy var forwardButtonItem: UIBarButtonItem! = nil
    private lazy var refreshButtonItem: UIBarButtonItem! = nil
    
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
    
    private var isbookmark = false {
        didSet {
            bookmarkButton.image = isbookmark ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        }
    }

    // Load View
    override func loadView() {
        super.loadView()
        view = webView
    }
    
    // MARK: - Life cycle View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationViewAndToolBar()
        loadWebView()
        saveReadArticle()
        checkBookmark()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: false)
    }
    
    // MARK: - NavigationView And ToolBar
    
    func setupNavigationViewAndToolBar() {
        backAllButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"),
                                            style: .done, target: self,
                                            action: #selector(backAllAction))
        bookmarkButton = UIBarButtonItem(image: UIImage(systemName: "star"),
                                         style: .done, target: self,
                                         action: #selector(onBookmark))
        forwardButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.right"),
                                            style: .plain, target: self,
                                            action: #selector(forwardAction))
        refreshButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh,
                                            target: self,
                                            action: #selector(refreshAction))
        backButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                         style: .done, target: self,
                                         action: #selector(backAction))
        
        navigationItem.leftBarButtonItems = [ backAllButtonItem]
        navigationItem.rightBarButtonItems = [ bookmarkButton ]
        
        let flexibleSpace = UIBarButtonItem(systemItem: .flexibleSpace)
        let fixedSpace = UIBarButtonItem(systemItem: .fixedSpace)
        fixedSpace.width = 50
        navigationController?.setToolbarHidden(false, animated: false)
        toolbarItems = [backButtonItem, fixedSpace, forwardButtonItem, flexibleSpace, refreshButtonItem]
    }
    
    // MARK: - Save favourite Articles by bookmarked
    
    // Insert stories when isbookmark = true
    func handleOnBookmark(storyURL: String, articleURL: String) {
        let fetchRequest = bookmarkedResultsController.fetchRequest
        fetchRequest.predicate = NSPredicate(value: true)
        try? bookmarkedResultsController.performFetch()
        let count = bookmarkedResultsController.fetchedObjects?.count ?? 0
        
        if !storyURL.isEmpty {
            guard let story = self.story else { return }
            insertArticle(title: story.title, webURL: story.webURL,
                          imageURL: story.multimedia?[2].url ?? "",
                          publishedDate: story.pubDate, index: count)
        } else if !articleURL.isEmpty {
            guard let article = self.article else { return }
            insertArticle(title: article.headline.main, webURL: article.webURL,
                          imageURL: "https://static01.nyt.com/" + (article.multimedia?[19].url ?? ""),
                          publishedDate: article.pubDate, index: count)
        } else { return }
    }
    
    //  Delete stories when isbookmark = false
    func handleFalseBookmark(storyURL: String, articleURL: String) {
        let urlString = resultsUrlString()
        filterWebURL(urlString: urlString)
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
        let storyURL = story?.webURL ?? ""
        let articleURL = article?.webURL ?? ""
        if isbookmark {
            // insert stories
            handleOnBookmark(storyURL: storyURL, articleURL: articleURL)
        } else {
            // delete stories
           handleFalseBookmark(storyURL: storyURL, articleURL: articleURL)
        }
    }
    
    @objc func refreshAction() {
        webView.reload()
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
    
    // MARK: - Save ReadArticle, Load webView and Check Bookmark
    
    // Save ReadArticle
    func saveReadArticle() {
        guard let story = story else { return }
        saveReadArticle(title: story.title, url: story.webURL, imageURL: story.multimedia?[2].url ?? "" , publishDate: Date())
    }
    
    func saveReadArticle(title: String, url: String, imageURL: String, publishDate: Date) {
        let context = persistentContainer.viewContext
        let newArticle = ReadArticle(context: context)
        newArticle.title = title
        newArticle.url = url
        newArticle.imageURL = imageURL
        newArticle.publishDate = publishDate
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // return UrlString
    func resultsUrlString() -> String {
        var urlString: String!
        let storyURL = story?.webURL ?? ""
        let articleURL = article?.webURL ?? ""
        if !storyURL.isEmpty {
            urlString = story!.webURL
            title = story!.title
        } else if !articleURL.isEmpty {
            urlString = article!.webURL
            title = article!.headline.main
        } else {
            urlString = bookmarkedArticle?.webURL
            title = bookmarkedArticle?.title
        }
        return urlString ?? ""
    }
    
    // load WebView
    func loadWebView() {
        let urlString = resultsUrlString()
        let urlRequest = URLRequest(url: URL(string: urlString)!)
        webView.load(urlRequest)
        webView.allowsBackForwardNavigationGestures = true
    }
    
    func filterWebURL(urlString: String) {
        let predicate = NSPredicate(format: "webURL == %@", urlString)
        bookmarkedResultsController.fetchRequest.predicate = predicate
        try? bookmarkedResultsController.performFetch()
    }
    
    // check bookmarked
    func checkBookmark() {
        let urlString = resultsUrlString()
        filterWebURL(urlString: urlString)
        let count = bookmarkedResultsController.fetchedObjects?.count ?? 0
        isbookmark = count > 0 ? true : false
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
    func insertArticle(title: String, webURL: String, imageURL: String, publishedDate: String, index: Int) {
        let context = persistentContainer.viewContext
        let newObject = BookmarkedArticle(context: context)
        newObject.title = title
        newObject.webURL = webURL
        newObject.imageURL = imageURL
        newObject.publishedDate = publishedDate
        newObject.index = Int32(index)
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}
