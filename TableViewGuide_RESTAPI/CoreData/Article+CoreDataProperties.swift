//
//  TopStories+CoreDataProperties.swift
//  TableViewGuide_RESTAPI
//
//  Created by Nguyễn Thịnh on 04/04/2023.
//
//

import Foundation
import CoreData

extension Article {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Article> {
        return NSFetchRequest<Article>(entityName: "Article")
    }

    @NSManaged public var imageURL: String?
    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var isRead: Bool
    @NSManaged public var published_date: String?

}

extension Article : Identifiable {

}
