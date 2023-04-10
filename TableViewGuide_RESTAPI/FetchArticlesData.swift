//
//  FetchData.swift
//  TableViewGuide_RESTAPI
//
//  Created by Nguyễn Thịnh on 09/04/2023.
//

import Foundation
import CoreData

class FetchArticlesData {
    static var fetchResultsController: NSFetchedResultsController<BookmartStories>!
    class func initFetchResultsController() {
        guard let context = AppDelegate.managedObjectContext else { return }
        let fetchRequest = BookmartStories.fetchRequest()
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
    
    static func insertTitlesStories(title: String, url_web: String, imageURL: String) {
        guard let context = AppDelegate.managedObjectContext else { return }
        let insertTitlesStories = NSEntityDescription.insertNewObject(forEntityName: "BookmartStories", into: context) as! BookmartStories
        insertTitlesStories.titles = title
        insertTitlesStories.url_web = url_web
        insertTitlesStories.imageURL = imageURL
        do {
            try context.save()
            try fetchResultsController.performFetch()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    static func filterFetchStories(urlFilter: String) {
        guard let context = AppDelegate.managedObjectContext else { return }
        let fetchRequest = BookmartStories.fetchRequest()
        let predicate = NSPredicate(format: "url_web == %@", urlFilter)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = []
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchResultsController.performFetch()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
