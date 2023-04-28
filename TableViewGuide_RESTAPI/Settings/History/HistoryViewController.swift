import UIKit
import CoreData

class HistoryViewController: UIViewController {

    private var tableView = UITableView()
    private var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 35))
        titleLabel.textAlignment = .center
        titleLabel.text = "No History"
        titleLabel.isHidden = true
        return titleLabel
    }()
    private let reuseIdentifier = "HistoryCell"
    
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
        let readArticle = readArticleResultsController.fetchedObjects ?? []
        
        if readArticle.isEmpty {
            titleLabel.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        let readArticle = readArticleResultsController.fetchedObjects ?? []
        
        if !readArticle.isEmpty {
            titleLabel.isHidden = true
        }
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
        titleLabel.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2 - 100)
        view.addSubview(titleLabel)
        setupNavigation()
    }
    
    func setupNavigation() {
        let clearHistory = UIBarButtonItem(title: "Clear History", style: .done, target: self, action: #selector(clearAction))
        navigationItem.rightBarButtonItems = [clearHistory]
    }
    
    @objc private func clearAction() {
        self.clearReadArticles()
        self.titleLabel.isHidden = false
        self.tableView.reloadData()
    }
    
    func publishDate(from publishDate: Date) -> Int {
        var date: String!
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month, .day], from: publishDate)
        if let year = components.year, let month = components.month, let day = components.day {
            date = "\((year * 1000000) + (month * 1000) + day)"
        }
        return Int(date) ?? 0
    }
    
    func checkPublishDate(_ inputDate: Int, will date: Date) -> String {
        let yesterdayDate = Date().addingTimeInterval(-60 * 60 * 24)

        let numericToday = Int(publishDate(from: Date()))
        let numericYesterday = Int(publishDate(from: yesterdayDate))
        
        if inputDate == numericToday {
            return "Today, " + dateFormatterForSectionHeader.string(from: date)
        } else if inputDate == numericYesterday {
            return "Yesterday, " + dateFormatterForSectionHeader.string(from: date)
        } else {
            return dateFormatterForSectionHeader.string(from: date)
        }
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

        let numericName = Int(sections[section].name) ?? 0
        let titleForHeader = checkPublishDate(numericName, will: date)
        
        return titleForHeader
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
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
            break
        @unknown default:
            print("No changed")
        }
    }
}
