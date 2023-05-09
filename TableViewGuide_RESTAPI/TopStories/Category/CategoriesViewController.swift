import UIKit

protocol CategoryValueDelegate: AnyObject {
    func categoryValue(_ sender: CategoriesViewController, category: String)
}

class CategoriesViewController: UIViewController {

    private let reuseIdentifiter = "CategoriesCell"
    private let userDefaults = UserDefaults.standard
    private let categoryKey = "category"
    private var categories: [String] = []
    public weak var delegate: CategoryValueDelegate!
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(origin: .zero, size: view.frame.size), style: .insetGrouped)
        view.addSubview(tableView)
        tableView.register(CategoriesCell.self, forCellReuseIdentifier: reuseIdentifiter)
        return tableView
    }()
    
    

    // MARK: - LifeCycle ViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.dataSource = self
        tableView.delegate = self
        initCategories()
    }
    
    func initCategories() {
        let categories = [
            "Arts", "Automobiles", "Books", "Business", "Fashion", "Food", "Health", "Home", "Insider", "Magazine", "Movies", "Nyregion", "Obituaries", "Opinion", "Politics", "Realestate", "Science", "Sports", "Sundayreview", "Technology", "Theater", "T-magazine", "Travel", "Upshot", "Us", "World"
        ]
        self.categories = categories
        
    }
}

// MARK: - DataSource and Delegate

extension CategoriesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifiter) as! CategoriesCell
        let category = userDefaults.string(forKey: categoryKey)
        cell.titleLabel.text = categories[indexPath.row]
        if category == categories[indexPath.row] {
            cell.isBookmark = true
        } else {
            cell.isBookmark = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let category = categories[indexPath.row]
        delegate.categoryValue(self, category: category)
        navigationController?.popViewController(animated: true)
    }
}
