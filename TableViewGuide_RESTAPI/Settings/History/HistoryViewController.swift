import UIKit
import CoreData

class HistoryViewController: UIViewController {

    private var tableView = UITableView()
    private let reuseIdentifier = "HistoryCell"
    private var articleResultsController: NSFetchedResultsController<Article>!
    private var readArticleResultsController: NSFetchedResultsController<ReadArticle>!
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        return dateFormatter
    }()
    
    private var dateFormatterForSectionHeader: DateFormatter {
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEE, MMMM dd, yyyy")
        return dateFormatter
    }
    
    private var dateFormatterForRowPublishTime: DateFormatter {
        dateFormatter.setLocalizedDateFormatFromTemplate("hh:mm a")
        return dateFormatter
    }
    
    override func loadView() {
        view = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        setupTableView()
        loadCache()
        loadReadArticle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func setupTableView() {
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
    
    func setupNavigation() {
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return readArticleResultsController.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return readArticleResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sections = readArticleResultsController.sections,
              let date = ReadArticle.date(from: sections[section].name)
        else { return nil }
        return dateFormatterForSectionHeader.string(from: date)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! HistoryCell
        let readArticle = readArticleResultsController.object(at: indexPath)
        cell.readArticle = readArticle
        
        if let publishDate = readArticle.publishDate {
            let publishTime = "\(dateFormatterForRowPublishTime.string(from: publishDate))"
            cell.publishTimeLabel.text = publishTime
        }
        return cell
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension HistoryViewController: NSFetchedResultsControllerDelegate {
    func loadCache() {
        guard let context = AppDelegate.managedObjectContext else { return }
        let fetchRequest = Article.fetchRequest()
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
    
    func loadReadArticle() {
        guard let context = AppDelegate.managedObjectContext else { return }
        let fetchRequest = ReadArticle.fetchRequest()
        let sort = NSSortDescriptor(key: "publishDate", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        readArticleResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: ReadArticle.Name.publishMonthID,
                                                                  cacheName: nil)
        readArticleResultsController.delegate = self
        do {
            try readArticleResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func clearReadArticles() {
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
