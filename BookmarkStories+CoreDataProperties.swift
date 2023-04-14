//
//  BookmartStories+CoreDataProperties.swift
//  TableViewGuide_RESTAPI
//
//  Created by Nguyễn Thịnh on 08/04/2023.
//
//

import Foundation
import CoreData


extension BookmarkStory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookmarkStory> {
        return NSFetchRequest<BookmarkStory>(entityName: "BookmarkStory")
    }

    @NSManaged public var title: String?
    @NSManaged public var url_web: String?
    @NSManaged public var imageURL: String?

}

extension BookmarkStory : Identifiable {

}
