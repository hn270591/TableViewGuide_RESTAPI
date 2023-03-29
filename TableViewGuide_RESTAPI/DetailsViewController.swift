//
//  DetailsViewController.swift
//  TableViewGuide_RESTAPI

import UIKit
import WebKit

class DetailsViewController: UIViewController, WKNavigationDelegate {

    // MARK: - Properties
    
    var stories: Story?
    var articles: Articles?
    private var webView: WKWebView!
    private var activityIndicator: UIActivityIndicatorView!
    private let refreshButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: .none, action: #selector(refeshAction))
    private let backButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .done, target: .none, action: #selector(backAction))
    private let forwardButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.right"), style: .plain, target: .none, action: #selector(forwardAction))
    
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
    }
    
    // Layout SubView
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupNavigationView()
    }
    
    private func setupWebView() {
        webView.navigationDelegate = self
        var url: URL!
        let detailsOfStoryURL = stories?.detailsOfStoryURL ?? ""
        let detailsOfArticlesURL = articles?.detailsURL ?? ""
        
        if detailsOfStoryURL.count != 0 {
            url = URL(string: detailsOfStoryURL)
            title = stories?.headline
        } else if detailsOfArticlesURL.count != 0 {
            url = URL(string: detailsOfArticlesURL)
            title = articles?.headLine
        } else {
            return
        }
        let urlRequest = URLRequest(url: url!)
        webView.load(urlRequest)
        webView.allowsBackForwardNavigationGestures = true
    }
    
    private func setupNavigationView() {
        backButtonItem.isEnabled = false
        forwardButtonItem.isEnabled = false
        let backAllButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .done, target: self, action: #selector(backAllAction))
        navigationItem.rightBarButtonItems = [ refreshButtonItem, forwardButtonItem ]
        navigationItem.leftBarButtonItems = [ backAllButtonItem, backButtonItem]
    }
    
    @objc private func refeshAction() {
        webView.reload()
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
