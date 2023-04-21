import UIKit
import CoreData

class HistoryViewController: UIViewController {

    private var tableView = UITableView()
    private let reuseIdentifier = "HistoryCell"
    private var articleResultsController: NSFetchedResultsController<TopStory>!
    private var readArticleResultsController: NSFetchedResultsController<ReadArticle>!
    
    override func loadView() {
        view = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        setupTableView()
        loadCache()
        loadReadArticle()
        readArticleResultsController.delegate = self
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(HistoryCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = 100
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupNavigation()
    }
    
    private func setupNavigation() {
        let clearHistory = UIBarButtonItem(title: "Clear History", style: .done, target: self, action: #selector(clearAction))
        navigationItem.rightBarButtonItems = [clearHistory]
    }
    
    @objc private func clearAction() {
        self.clearReadArticles()
        self.tableView.reloadData()
    }
}

// MARK: - TableView Datasource and Delegate

extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = readArticleResultsController?.fetchedObjects?.count ?? 0
        return count > 0 ? count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! HistoryCell
        let count = readArticleResultsController?.fetchedObjects?.count ?? 0
        if count > 0 {
            let article = readArticleResultsController?.object(at: indexPath)
            cell.readArticle = article
        }
        return cell
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension HistoryViewController: NSFetchedResultsControllerDelegate {
    private func loadCache() {
        guard let context = AppDelegate.managedObjectContext else { return }
        let fetchRequest = TopStory.fetchRequest()
        fetchRequest.sortDescriptors = []
        articleResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                            managedObjectContext: context,
                                                            sectionNameKeyPath: nil,
                                                            cacheName: nil)
        do {
            try articleResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func loadReadArticle() {
        guard let context = AppDelegate.managedObjectContext else { return }
        let fetchRequest = ReadArticle.fetchRequest()
        let sort = NSSortDescriptor(key: "index", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        readArticleResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                            managedObjectContext: context,
                                                            sectionNameKeyPath: nil,
                                                            cacheName: nil)
        do {
            try readArticleResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func clearReadArticles() {
        guard let context = AppDelegate.managedObjectContext else { return }
        let fetchRequestResult = NSFetchRequest<NSFetchRequestResult>(entityName: "ReadArticle")
        let batchDelete = NSBatchDeleteRequest(fetchRequest: fetchRequestResult)
        do {
            try context.execute(batchDelete)
            try context.save()
            try readArticleResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
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
