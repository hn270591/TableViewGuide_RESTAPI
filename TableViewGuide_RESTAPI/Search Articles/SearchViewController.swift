import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var articles: [ArticleItem] = []
    
    private let reuseIdentifierLoadingCell = "LoadingCell"
    private let placeholderSearch = "Search"
    private let heightForRowOfArticlesCell: CGFloat = 100
    private let heightForRowOfLoadingCell: CGFloat = 50
    private let animationDurationTableView: TimeInterval = 1
    private var page: Int = 0
    private var isLoading: Bool = false
    private var searchText: String = ""
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = placeholderSearch
        searchBar.becomeFirstResponder()
        navigationItem.titleView = searchBar
        return searchBar
    }()
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        indicatorView.center = view.center
        view.addSubview(indicatorView)
        indicatorView.startAnimating()
        return indicatorView
    }()
    
    enum Titles {
        static let internetError = "No Internet"
    }
    
    enum Messages {
        static let checkNetwork = "Checking the network cables, modem, and router."
    }
    
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default)
        alert.addAction(ok)
        present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(LoadingCell.self, forCellReuseIdentifier: reuseIdentifierLoadingCell)
        searchBar.delegate = self
    }
}

// MARK: - TableVview DataSource and Delegate

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return articles.count
        case 1:
            return isLoading ? 1 : 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchArticlesCell", for: indexPath) as! SearchArticlesCell
            cell.article = articles[indexPath.row]
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierLoadingCell, for: indexPath) as! LoadingCell
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vcDetails = DetailsViewController()
        vcDetails.article = articles[indexPath.row]
        vcDetails.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vcDetails, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return heightForRowOfArticlesCell
        } else {
            return heightForRowOfLoadingCell
        }
    }
}

// MARK: - Search ViewController

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        self.activityIndicatorView.startAnimating()
        if !articles.isEmpty {
            self.articles.removeAll()
            isLoading = false
            self.page = 0
            self.tableView.reloadData()
        }
        
        if let searchText = searchBar.text {
            var textArray: [Character] = []
            for text in searchText {
                textArray.append(text)
                if let valueChange = textArray.firstIndex(of: " ") {
                    textArray[valueChange] = "+"
                }
            }
            self.searchText = String(textArray)
            self.isLoading = true
            BaseReponse.shared.articleResponse(query: self.searchText, page: self.page, completion: { articles, error in
                self.activityIndicatorView.stopAnimating()
                if let error = error {
                    self.handleError(error)
                    return
                }
                self.articles = articles
                UIView.transition(with: self.tableView,duration: self.animationDurationTableView,options: .transitionCrossDissolve)
                { self.tableView.reloadData() }
                // show activityIndicatorView khi load page 1
                self.isLoading = false
            })
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        searchBar.text = ""
        page = 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == articles.count - 1, !isLoading {
            loadMoreData()
            print("NameQuery: \(self.searchText), page: \(self.page + 1)")
        }
    }
    
    func loadMoreData() {
        if !self.isLoading {
            self.isLoading = true
            let nextPage = self.page + 1
            
            BaseReponse.shared.articleResponse(query: self.searchText, page: nextPage, completion: { articles, error in
                if let error = error {
                    self.handleError(error)
                    return
                }
                self.articles = self.articles + articles
                self.tableView.reloadData()
                self.page = self.page + 1
                self.isLoading = false
            })
        }
    }
    
    func handleError(_ error: BaseResponseError) {
        switch error {
        case .inConnect:
            DispatchQueue.main.async {
                self.alert(title: Titles.internetError, message: Messages.checkNetwork)
            }
            break
        case .invalidResponse:
            DispatchQueue.global().asyncAfter(deadline: .now() + 30) {
                BaseReponse.shared.articleResponse(query: self.searchText, page: self.page + 1, completion: { articles, error in
                    if let error = error {
                        self.handleError(error)
                        return
                    }
                    self.articles = self.articles + articles
                    self.tableView.reloadData()
                    self.page = self.page + 1
                    self.isLoading = false
                })
            }
            break
        case .invalidData:
            print("Invalid Data")
        }
    }
}


