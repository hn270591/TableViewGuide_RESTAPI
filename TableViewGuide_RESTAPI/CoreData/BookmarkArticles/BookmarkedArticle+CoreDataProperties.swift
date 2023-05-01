//
//  BookmartStories+CoreDataProperties.swift
//  TableViewGuide_RESTAPI
//
//  Created by Nguyễn Thịnh on 08/04/2023.
//
//

import Foundation
import CoreData


extension BookmarkedArticle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookmarkedArticle> {
        return NSFetchRequest<BookmarkedArticle>(entityName: "BookmarkedArticle")
    }

    @NSManaged public var title: String?
    @NSManaged public var webURL: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var publishedDate: String?

}

extension BookmarkedArticle : Identifiable {

}
