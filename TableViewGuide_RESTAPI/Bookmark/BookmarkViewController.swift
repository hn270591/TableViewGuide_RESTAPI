//
//  BookmarkViewController.swift
//  TableViewGuide_RESTAPI
//
//  Created by Nguyễn Thịnh on 08/04/2023.
//

import UIKit
import CoreData

class BookmarkViewController: UIViewController {

    private var tableView = UITableView()
    private let reuseIdentifier = "BookmarkCell"
    private var searchController = UISearchController()
    private var fetchResultsController: NSFetchedResultsController<BookmarkStory>!
    
    override func loadView() {
        view = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Favorites"
        setupTableView()
        initFetchResultsController()
        fetchResultsController.delegate = self
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
        tableView.register(BookmarkCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = 100
    }
}

// MARK: - TableView Datasource and Delegate

extension BookmarkViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = fetchResultsController?.fetchedObjects?.count ?? 0
        if count != 0 {
            print("Count: \(count)")
            return count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! BookmarkCell
        let count = fetchResultsController?.fetchedObjects?.count ?? 0
        if count == 0 {
            return cell
        }
        let storiesAtIndex = fetchResultsController?.object(at: indexPath)
        cell.bookmarkStory = storiesAtIndex
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vcDetails = storyboard?.instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
        let bookmarkStory = fetchResultsController?.object(at: indexPath)
        vcDetails.bookmarkStory = bookmarkStory
        vcDetails.hidesBottomBarWhenPushed = true
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.pushViewController(vcDetails, animated: true)
    }
}

// MARK: - SearchController

extension BookmarkViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        if searchText.isEmpty {
            initFetchResultsController()
        } else {
            fetchFilterBookmartStories(searchText: searchText)
        }
        fetchResultsController.delegate = self
        self.tableView.reloadData()
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension BookmarkViewController: NSFetchedResultsControllerDelegate {
    
    private func initFetchResultsController() {
        guard let context = AppDelegate.managedObjectContext else { return }
        let fetchRequest = BookmarkStory.fetchRequest()
        fetchRequest.sortDescriptors = []
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                            managedObjectContext: context,
                                                            sectionNameKeyPath: nil,
                                                            cacheName: nil)
        do {
            try fetchResultsController.performFetch()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private func fetchFilterBookmartStories(searchText: String) {
        guard let context = AppDelegate.managedObjectContext else { return }
        let fetchRequest = BookmarkStory.fetchRequest()
        let predicate = NSPredicate(format: "title contains %@", searchText)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = []
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchResultsController.performFetch()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let context = AppDelegate.managedObjectContext else { return }
            let deleteStories = fetchResultsController?.object(at: indexPath)
            context.delete(deleteStories!)
            do {
                try context.save()
                try fetchResultsController?.performFetch()
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
