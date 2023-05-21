import UIKit

protocol CategoriesViewControllerDelegate: AnyObject {
    func setCategoryValue(_ sender: CategoriesViewController, category: String)
}

class CategoriesViewController: UIViewController {

    private let reuseIdentifiter = "CategoriesCell"
    private var categories: [String] = ["Arts", "Automobiles", "Books", "Business", "Fashion", "Food", "Health", "Home", "Insider", "Magazine", "Movies", "Nyregion", "Obituaries", "Opinion", "Politics", "Realestate", "Science", "Sports", "Sundayreview", "Technology", "Theater", "T-magazine", "Travel", "Upshot", "Us", "World"]
    public weak var delegate: CategoriesViewControllerDelegate!
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
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
        
        // Notification when changed font size
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(updateUI), name: FontUpdateNotification, object: nil)
    }
    
    @objc func updateUI() {
        tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
}

// MARK: - DataSource and Delegate

extension CategoriesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifiter) as! CategoriesCell
        let category = CategoryManger.shared.currentCategory
        let selected = category == categories[indexPath.row]
        cell.titleLabel.text = categories[indexPath.row]
        cell.titleLabel.font = .fontOfHeadline()
        cell.isCheckmark = selected  ? true : false
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let category = categories[indexPath.row]
        delegate.setCategoryValue(self, category: category)
        navigationController?.popViewController(animated: true)
    }
}
