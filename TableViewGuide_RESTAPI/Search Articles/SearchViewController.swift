
import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var articles: [ArticleItem] = []
    private var searchBar = UISearchBar()
    private var activityIndicatorView = UIActivityIndicatorView()
    private let reuseIdentifierLoadingCell = "LoadingCell"
    private let placeholderSearch = "Search"
    private let heightForRowOfArticlesCell: CGFloat = 100
    private let heightForRowOfLoadingCell: CGFloat = 50
    private let animationDurationTableView: TimeInterval = 1
    private var loadingCell: LoadingCell?
    private var numberPage: Int = 0
    private var isLoading: Bool = false
    private var searchText: String = ""
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(LoadingCell.self, forCellReuseIdentifier: reuseIdentifierLoadingCell)
        
        searchBar.delegate = self
        searchBar.placeholder = placeholderSearch
        searchBar.becomeFirstResponder()
        navigationItem.titleView = searchBar
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupIndicationView()
    }
    
    private func setupIndicationView() {
        activityIndicatorView.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
        activityIndicatorView.center = CGPoint(x: (UIScreen.main.bounds.width) / 2, y: (UIScreen.main.bounds.height) / 2)
        activityIndicatorView.hidesWhenStopped = true
        view.addSubview(activityIndicatorView)
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
            if isLoading {
                return 1
            } else {
                return 0
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "collectionCell", for: indexPath) as! SearchArticlesCell
            cell.articles = articles[indexPath.row]
            return cell
        } else if indexPath.section == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierLoadingCell, for: indexPath) as! LoadingCell
            self.loadingCell = cell
                return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vcDetails = storyboard?.instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
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
            self.numberPage = 0
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
            BaseReponse.shared.ariticleResponse(queryName: self.searchText, numberPage: self.numberPage, completion: { articles, error in
                if let error = error {
                    self.handlerError(error: error)
                    self.activityIndicatorView.stopAnimating()
                    return
                }
                self.articles = articles
                self.activityIndicatorView.stopAnimating()
                UIView.transition(with: self.tableView,
                                  duration: self.animationDurationTableView,
                                  options: .transitionCrossDissolve)
                {
                    self.tableView.reloadData()
                } completion: { _ in
                    self.isLoading = false
                }
    
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
        numberPage = 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            self.loadingCell?.activityIndicatorView.startAnimating()
        }

        if indexPath.row == articles.count - 1, !isLoading {
            loadMoreData()
            print("NameQuery: \(self.searchText), page: \(self.numberPage + 1)")
        }
    }
    
    private func loadMoreData() {
        if !self.isLoading {
            self.isLoading = true
            let nextPage = self.numberPage + 1
            
            BaseReponse.shared.ariticleResponse(queryName: self.searchText, numberPage: nextPage, completion: { articles, error in
                if let error = error {
                    self.handlerError(error: error)
                    return
                }
                self.articles = self.articles + articles
                self.tableView.reloadData()
                self.numberPage = self.numberPage + 1
                self.isLoading = false
            })
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            self.loadingCell?.activityIndicatorView.stopAnimating()
        }
    }
    
    private func handlerError(error: BaseResponseError) {
        switch error {
        case .inConnect:
            DispatchQueue.main.async {
                self.alert(title: Titles.internetError, message: Message.checkNetwork)
            }
            break
        case .invalidResponse:
            DispatchQueue.global().asyncAfter(deadline: .now() + 30) {
                BaseReponse.shared.ariticleResponse(queryName: self.searchText, numberPage: self.numberPage + 1, completion: { articles, error in
                    if let error = error {
                        self.handlerError(error: error)
                        return
                    }
                    self.articles = self.articles + articles
                    self.tableView.reloadData()
                    self.numberPage = self.numberPage + 1
                    self.isLoading = false
                })
            }
            break
        case .invalidData:
            print("Invalid Data")
        }
    }
}


