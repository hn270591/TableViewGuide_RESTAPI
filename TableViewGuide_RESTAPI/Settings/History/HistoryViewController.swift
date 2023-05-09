import UIKit
import CoreData

class HistoryViewController: UIViewController {
    
    private let reuseIdentifier = "HistoryCell"
    private let message: String = "Are you want to delete ?"
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(HistoryCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = 100
        return tableView
    }()
    
    private lazy var noHistoryLabel: UILabel = {
        let noHistoryLabel = UILabel()
        noHistoryLabel.textAlignment = .center
        noHistoryLabel.text = "No History"
        noHistoryLabel.isHidden = true
        noHistoryLabel.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2 - 100)
        view.addSubview(noHistoryLabel)
        return noHistoryLabel
    }()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate!.persistenContainer
    }()
    
    private lazy var readArticleResultsController: NSFetchedResultsController<ReadArticle> = {
        let fetchRequest = ReadArticle.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: ReadArticle.Name.publishDate, ascending: false)]
    let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                managedObjectContext: persistentContainer.viewContext,
                                                sectionNameKeyPath: ReadArticle.Name.publishDayID, cacheName: nil)
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
        tableView.dataSource = self
        tableView.delegate = self
        setupNavigation()
        navigationController?.navigationBar.prefersLargeTitles = false
        let readArticle = readArticleResultsController.fetchedObjects ?? []
        
        if readArticle.isEmpty {
            noHistoryLabel.isHidden = false
        }
    }
    
    func setupNavigation() {
        lazy var clearHistory = UIBarButtonItem(title: "Clear History", style: .done, target: self, action: #selector(clearAction))
        navigationItem.rightBarButtonItems = [clearHistory]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        let readArticle = readArticleResultsController.fetchedObjects ?? []
        
        if !readArticle.isEmpty {
            noHistoryLabel.isHidden = true
        }
    }
    
    // Alert
    func alert(title: String?, message: String, handler: @escaping (() -> Void)) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) {_ in
            handler()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    @objc func clearAction() {
        alert(title: nil, message: message, handler: {
            self.clearReadArticles()
            self.noHistoryLabel.isHidden = false
            self.tableView.reloadData()
        })
    }
}

// MARK: - TableView Datasource and Delegate

extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return readArticleResultsController.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return readArticleResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sections = readArticleResultsController.sections else { return nil }
        let title = sections[section].name
        return title
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! HistoryCell
        let readArticle = readArticleResultsController.object(at: indexPath)
        cell.readArticle = readArticle
        
        if let publishDate = readArticle.publishDate {
            let publishTime = DateFormatter.dateFormatterForRowPublishTime(date: publishDate)
            cell.createdTimeLabel.text = publishTime
        }
        return cell
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension HistoryViewController: NSFetchedResultsControllerDelegate {    
    func clearReadArticles() {
        let context = persistentContainer.viewContext
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
            let readArticle = readArticleResultsController.fetchedObjects ?? []
            if readArticle.count > 1 {
                if let newIndexPath = newIndexPath {
                    self.tableView.insertRows(at: [newIndexPath], with: .fade)
                } 
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
