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
    private let reuseIdentifier = "BookmartCell"
    private var fetchResultsController: NSFetchedResultsController<BookmartStories>!
    
    override func loadView() {
        view = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Favorites"
        setupTableView()
        getDataStories()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        getDataStories()
        self.tableView.reloadData()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(BookmartCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = 40
    }
    
    private func getDataStories() {
        FetchArticlesData.initFetchResultsController()
        FetchArticlesData.fetchResultsController.delegate = self
        fetchResultsController = FetchArticlesData.fetchResultsController
    }
}

// MARK: - TableView Datasource and Delegate

extension BookmarkViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = fetchResultsController.fetchedObjects?.count ?? 0
        if count != 0 {
            print("Count: \(count)")
            return count
        } else {
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! BookmartCell
        let count = fetchResultsController.fetchedObjects?.count ?? 0
        if count == 0 {
            cell.titleLabel.text = ""
            return cell
        }
        let storiesAtIndex = fetchResultsController.object(at: indexPath)
        cell.titleLabel.text = storiesAtIndex.titles
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vcDetails = storyboard?.instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
        let bookmartStories = fetchResultsController.object(at: indexPath)
        vcDetails.bookmartStories = bookmartStories
        vcDetails.hidesBottomBarWhenPushed = true
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.pushViewController(vcDetails, animated: true)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension BookmarkViewController: NSFetchedResultsControllerDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let context = AppDelegate.managedObjectContext else { return }
            let fetchResultsController = FetchArticlesData.fetchResultsController
            guard let deleteStories = fetchResultsController?.object(at: indexPath) else {
                return
            }
            context.delete(deleteStories)
            do {
                try context.save()
                try fetchResultsController?.performFetch()
            } catch {
                fatalError(error.localizedDescription)
            }
            self.fetchResultsController = fetchResultsController
            self.tableView.reloadData()
        }
    }
}
