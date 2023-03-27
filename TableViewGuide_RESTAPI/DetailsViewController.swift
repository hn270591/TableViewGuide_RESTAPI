//
//  DetailsViewController.swift
//  TableViewGuide_RESTAPI

import UIKit
import WebKit

class DetailsViewController: UIViewController, WKNavigationDelegate {

    // MARK: - Properties
    
    var stories: Story!
    private var webView: WKWebView!
    private var activityIndicator: UIActivityIndicatorView!
    private let toolBar = UIToolbar()
    private let refreshButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: .none, action: #selector(refeshAction))
    private let spacingItem1 = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
    private let spacingItem2 = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
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
        guard
            let detailsURL = stories.detailsOfArticles,
            let url = URL(string: detailsURL)
        else { return }
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    
    // Layout SubView
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backButtonItem.isEnabled = false
        forwardButtonItem.isEnabled = false
        
        toolBar.items = [spacingItem1, backButtonItem,spacingItem2, forwardButtonItem]
        navigationItem.rightBarButtonItem = refreshButtonItem
        
        view.addSubview(toolBar)
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        toolBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        toolBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        toolBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
        toolBar.heightAnchor.constraint(equalToConstant: 40).isActive = true
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
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        backButtonItem.isEnabled = webView.canGoBack
        forwardButtonItem.isEnabled = webView.canGoForward
    }
}
