
import UIKit
import CoreData
import WebKit

class DetailsViewController: UIViewController, WKNavigationDelegate {

    // MARK: - Properties
    
    var bookmartStories: BookmartStories!
    var stories: Story?
    var articles: ArticleItem?
    private var webView: WKWebView!
    private var activityIndicator: UIActivityIndicatorView!
    private var toolBar = UIToolbar()
    
    private let bookmartButton = UIBarButtonItem(image: UIImage(systemName: "star"),
                                                 style: .done, target: .none,
                                                 action: #selector(onBookmart))
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
                                                    action: #selector(refeshAction))
    
    private var isbookmark = false {
        didSet {
            bookmartButton.image = isbookmark ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
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
        FetchArticlesData.initFetchResultsController()
        FetchArticlesData.fetchResultsController.delegate = self
        setupWebView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupWebView()
    }
    
    private func resultsUrlString() -> String {
        var urlString: String!
        let countOfStoriesURL = stories?.url.count ?? 0
        let countOfArticlesURL = articles?.web_url.count ?? 0
        
        if countOfStoriesURL != 0 {
            urlString = stories!.url
            title = stories!.title
        } else if countOfArticlesURL != 0 {
            urlString = articles!.web_url
            title = articles!.headline.main
        } else {
            urlString = bookmartStories.url_web
            title = bookmartStories.titles
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
        
        FetchArticlesData.filterFetchStories(urlFilter: urlString)
        let count = FetchArticlesData.fetchResultsController.fetchedObjects?.count ?? 0
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
        bookmartButton.target = self
        navigationItem.leftBarButtonItems = [ backAllButtonItem]
        navigationItem.rightBarButtonItems = [ bookmartButton ]
        
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
    
    @objc private func refeshAction() {
        webView.reload()
    }
    
    // Setup Bookmart
    @objc private func onBookmart() {
        isbookmark.toggle()
        let countOfStoriesURL = self.stories?.url.count ?? 0
        let countOfArticlesURL = self.articles?.web_url.count ?? 0
        if isbookmark {
            // insert stories
            if countOfStoriesURL != 0 {
                FetchArticlesData.insertTitlesStories(title: self.stories!.title,
                                                      url_web: self.stories!.url,
                                                      imageURL: self.stories!.multimedia[2].url)
            } else if countOfArticlesURL != 0 {
                FetchArticlesData.insertTitlesStories(title: self.articles!.headline.main,
                                                      url_web: self.articles!.web_url,
                                                      imageURL: self.articles!.multimedia[19].url)
            } else {
                return
            }
        } else {
            // delete stories
            let urlString = resultsUrlString()
            FetchArticlesData.filterFetchStories(urlFilter: urlString)
            let deleteStories = FetchArticlesData.fetchResultsController.object(at: IndexPath(item: 0, section: 0))
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
        activityIndicator.stopAnimating()
        backButtonItem.isEnabled = webView.canGoBack
        forwardButtonItem.isEnabled = webView.canGoForward
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension DetailsViewController: NSFetchedResultsControllerDelegate {
    //
}
