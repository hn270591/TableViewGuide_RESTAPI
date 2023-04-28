import UIKit
import CoreData

struct ReadArticles: Hashable {
    var headline: String
    var thumbnail: String
    var createdDate: String
    var createdTime: String
}

class HistoryViewController: UIViewController {

    private var tableView = UITableView()
    private let reuseIdentifier = "HistoryCell"
    private var readArticles: [(String, [ReadArticles])] = []
    private var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 35))
        titleLabel.textAlignment = .center
        titleLabel.text = "No History"
        titleLabel.isHidden = true
        return titleLabel
    }()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let appDalegate = UIApplication.shared.delegate as? AppDelegate
        return appDalegate!.persistenContainer
    }()
    
    private lazy var articleResultsController: NSFetchedResultsController<Article> = {
        let fetchRequest = Article.fetchRequest()
        fetchRequest.sortDescriptors = []
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: persistentContainer.viewContext,
                                                    sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        do {
            try controller.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        return controller
    }()
    
    private lazy var readArticleResultsController: NSFetchedResultsController<ReadArticle> = {
        let fetchRequest = ReadArticle.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: false)]
    let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                managedObjectContext: persistentContainer.viewContext,
                                                sectionNameKeyPath: nil, cacheName: nil)
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
        navigationController?.navigationBar.prefersLargeTitles = true
        setupTableView()
        readArticles = readArticlesArray()
        
        if readArticles.isEmpty {
            titleLabel.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    
        if !readArticles.isEmpty {
            titleLabel.isHidden = true
        }
    }
    
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
    
    func createdDate(from createdDate: Date) -> Int {
        var date: String!
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month, .day], from: createdDate)
        if let year = components.year, let month = components.month, let day = components.day {
            date = "\((year * 1000000) + (month * 1000) + day)"
        }
        return Int(date) ?? 0
    }
    
    func checkCreatedDate(_ inputDate: Int, will date: Date) -> String {
        let yesterdayDate = Date().addingTimeInterval(-60 * 60 * 24)

        let numericToday = Int(createdDate(from: Date()))
        let numericYesterday = Int(createdDate(from: yesterdayDate))
        
        if inputDate == numericToday {
            return "Today, " + dateFormatterForSectionHeader.string(from: date)
        } else if inputDate == numericYesterday {
            return "Yesterday, " + dateFormatterForSectionHeader.string(from: date)
        } else {
            return dateFormatterForSectionHeader.string(from: date)
        }
    }
    
    func readArticlesArray() -> [(String, [ReadArticles])] {
        var readArticles: [(String, [ReadArticles])] = []
        let grouping = Dictionary(grouping: getReadArticles()) { $0.createdDate }
        for (key,value) in grouping {
            readArticles.append((key,value))
        }
        return readArticles
    }
    
    func getReadArticles() -> [ReadArticles] {
        var readArticlesResults: [ReadArticles] = []
        let readArticles = readArticleResultsController.fetchedObjects ?? []
        if !readArticles.isEmpty {
            for index in 0..<readArticles.count {
                let indexPath = IndexPath(row: index, section: 0)
                let readArticle = readArticleResultsController.object(at: indexPath)
                
                let headline = readArticle.title!
                let thumbnail = readArticle.imageURL!
                
                let date = readArticle.createdDate!
                let numericDate = createdDate(from: date)
                let dateString = checkCreatedDate(numericDate, will: date)
                let timeString = dateFormatterForRowPublishTime.string(from: date)
                
                let readArticleResults = ReadArticles(headline: headline, thumbnail: thumbnail, createdDate: dateString, createdTime: timeString)
                
                readArticlesResults.append(readArticleResults)
            }
        }
        return readArticlesResults
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
        self.readArticles.removeAll()
        self.clearReadArticles()
        self.tableView.reloadData()
    }
}

// MARK: - TableView Datasource and Delegate

extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return readArticles.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return readArticles[section].0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return readArticles[section].1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! HistoryCell
        cell.readArticles = readArticles[indexPath.section].1[indexPath.row]
        return cell
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension HistoryViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) { 
        let readArticless = readArticleResultsController.fetchedObjects ?? []
        if readArticless.count == 1 {
            self.readArticles = readArticlesArray()
            tableView.reloadData()
        } else {
            self.readArticles = readArticlesArray()
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }
    
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
}

