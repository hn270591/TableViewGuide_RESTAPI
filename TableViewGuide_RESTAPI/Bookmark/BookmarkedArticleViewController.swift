import UIKit
import CoreData

class BookmarkedArticleViewController: UIViewController {

    private var tableView = UITableView()
    private let reuseIdentifier = "BookmarkedArticleCell"
    private var searchController = UISearchController()
    private var bookmarkedResultsController: NSFetchedResultsController<BookmarkedArticle>!
    
    override func loadView() {
        view = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Favorites"
        setupTableView()
        loadBookmarkedArticle()
        bookmarkedResultsController.delegate = self
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(BookmarkedArticleCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = 100
    }
}

// MARK: - TableView Datasource and Delegate

extension BookmarkedArticleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = bookmarkedResultsController?.fetchedObjects?.count ?? 0
        return count > 0 ? count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! BookmarkedArticleCell
        let count = bookmarkedResultsController?.fetchedObjects?.count ?? 0
        if count > 0 {
            let object = bookmarkedResultsController?.object(at: indexPath)
            cell.bookmarkStory = object
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vcDetails = storyboard?.instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
        let object = bookmarkedResultsController?.object(at: indexPath)
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
            loadBookmarkedArticle()
        } else {
            searchArticle(searchText: searchText)
        }
        bookmarkedResultsController.delegate = self
        self.tableView.reloadData()
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension BookmarkedArticleViewController: NSFetchedResultsControllerDelegate {
    
    private func loadBookmarkedArticle() {
        guard let context = AppDelegate.managedObjectContext else { return }
        let fetchRequest = BookmarkedArticle.fetchRequest()
        fetchRequest.sortDescriptors = []
        bookmarkedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                            managedObjectContext: context,
                                                            sectionNameKeyPath: nil,
                                                            cacheName: nil)
        do {
            try bookmarkedResultsController.performFetch()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private func searchArticle(searchText: String) {
        guard let context = AppDelegate.managedObjectContext else { return }
        let fetchRequest = BookmarkedArticle.fetchRequest()
        let predicate = NSPredicate(format: "title contains %@", searchText)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = []
        bookmarkedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try bookmarkedResultsController.performFetch()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let context = AppDelegate.managedObjectContext else { return }
            let deleteStories = bookmarkedResultsController?.object(at: indexPath)
            context.delete(deleteStories!)
            do {
                try context.save()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                self.tableView.insertRows(at: [newIndexPath], with: .fade)
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
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
            break
        @unknown default:
            print("No changed")
        }
    }
}
