import UIKit
import CoreData

class BookmarkedArticleViewController: UIViewController {
    
    private let reuseIdentifier = "BookmarkedArticleCell"
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(BookmarkedArticleCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = 100
        return tableView
    }()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        navigationItem.searchController = searchController
        return searchController
    }()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate!.persistenContainer
    }()
    
    private lazy var bookmarkedResultsController: NSFetchedResultsController<BookmarkedArticle> = {
        let fetchRequest = BookmarkedArticle.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "index", ascending: false)]
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                 managedObjectContext: persistentContainer.viewContext,
                                                                 sectionNameKeyPath: nil,cacheName: nil)
        controller.delegate = self
        do {
            try controller.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        return controller
    }()
    
    override func loadView() {
        view = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Favorites"
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.dataSource = self
        tableView.delegate = self
        searchController.searchResultsUpdater = self
        
        // Notification when changed font size
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(updateUI), name: FontUpdateNotification, object: nil)
    }
    
    @objc func updateUI() {
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}

// MARK: - TableView Datasource and Delegate

extension BookmarkedArticleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = bookmarkedResultsController.fetchedObjects?.count ?? 0
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! BookmarkedArticleCell
        cell.configureUI()
        let count = bookmarkedResultsController.fetchedObjects?.count ?? 0
        if count > 0 {
            let object = bookmarkedResultsController.object(at: indexPath)
            cell.bookmarkStory = object
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vcDetails = DetailsViewController()
        let object = bookmarkedResultsController.object(at: indexPath)
        vcDetails.bookmarkedArticle = object
        vcDetails.hidesBottomBarWhenPushed = true
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.pushViewController(vcDetails, animated: true)
    }
}

// MARK: - SearchController

extension BookmarkedArticleViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        if searchText.isEmpty {
            bookmarkedResultsController.fetchRequest.predicate = NSPredicate(value: true)
            try? bookmarkedResultsController.performFetch()
        } else {
            bookmarkedResultsController.fetchRequest.predicate = NSPredicate(format: "title contains %@", searchText)
            try? bookmarkedResultsController.performFetch()
        }
        self.tableView.reloadData()
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension BookmarkedArticleViewController: NSFetchedResultsControllerDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = persistentContainer.viewContext
            let deleteStories = bookmarkedResultsController.object(at: indexPath)
            context.delete(deleteStories)
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            let readArticle = bookmarkedResultsController.fetchedObjects ?? []
            if readArticle.count > 1 {
                guard let newIndexPath = newIndexPath else { return }
                self.tableView.insertRows(at: [newIndexPath], with: .fade)
            } else {
                self.tableView.reloadData()
            }
            break
        case .delete:
            if let indexPath = indexPath {
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break
        case .move:
            print("move")
        case .update:
            if let indexPath = indexPath {
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
            break
        @unknown default:
            print("No changed")
        }
    }
}
