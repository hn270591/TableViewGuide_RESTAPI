//
//  BookmartStories+CoreDataProperties.swift
//  TableViewGuide_RESTAPI
//
//  Created by Nguyễn Thịnh on 08/04/2023.
//
//

import Foundation
import CoreData


extension BookmartStories {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookmartStories> {
        return NSFetchRequest<BookmartStories>(entityName: "BookmartStories")
    }

    @NSManaged public var titles: String?
    @NSManaged public var url_web: String?

}

extension BookmartStories : Identifiable {

}
