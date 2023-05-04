import UIKit
import CoreData

class CategoryViewController: UIViewController {

    let reuseIdentifiter = "CategoryCell"
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(origin: .zero, size: view.frame.size), style: .insetGrouped)
        view.addSubview(tableView)
        tableView.register(CategoryCell.self, forCellReuseIdentifier: reuseIdentifiter)
        return tableView
    }()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate!.persistenContainer
    }()

    private lazy var categoryResultsController: NSFetchedResultsController<CategoryTopStories> = {
        let fetchRequest = CategoryTopStories.fetchRequest()
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

    // MARK: - LifeCycle ViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.dataSource = self
        tableView.delegate = self
        
        let category = categoryResultsController.fetchedObjects ?? []
        if category.isEmpty {
            saveCategory()
        }
    }
}

// MARK: - DataSource and Delegate

extension CategoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifiter) as! CategoryCell
        let object = categoryResultsController.object(at: indexPath)
        cell.category = object
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        updateRows(indexPath: indexPath)
    }
    
    func updateRows(indexPath: IndexPath) {
        // update hide checkmart
        try? categoryResultsController.performFetch()
        let isBookmark = categoryResultsController.fetchedObjects?.compactMap({ $0.isBookmark })
        if let index = isBookmark?.firstIndex(of: true) {
            let indexPath = IndexPath(row: index, section: 0)
            let object = categoryResultsController.object(at: indexPath)
            object.isBookmark = false

            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
        
        // When a row is selected, show checkmark at indexPath
        let object = categoryResultsController.object(at: indexPath)
        object.isBookmark = true
        do {
            try persistentContainer.viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
        
        self.tableView.reloadRows(at: [indexPath], with: .none)

    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension CategoryViewController: NSFetchedResultsControllerDelegate {
    func saveCategory(title: String, isBookmark: Bool) {
        let context = persistentContainer.viewContext
        let newObject = CategoryTopStories(context: context)
        newObject.title = title
        newObject.isBookmark = isBookmark
        do {
            try context.save()
            try categoryResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }

    func saveCategory() {
        let categoryArray = [
            "Arts", "Automobiles", "Books", "Business", "Fashion", "Food", "Health", "Home", "Insider", "Magazine", "Movies", "Nyregion", "Obituaries", "Opinion", "Politics", "Realestate", "Science", "Sports", "Sundayreview", "Technology", "Theater", "T-magazine", "Travel", "Upshot", "Us", "World"
        ]
        for title in categoryArray {
            if title == "Home" {
                saveCategory(title: title, isBookmark: true)
            } else {
                saveCategory(title: title, isBookmark: false)
            }
        }
    }
}
