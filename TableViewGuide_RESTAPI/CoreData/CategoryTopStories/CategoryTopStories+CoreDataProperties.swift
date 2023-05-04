//
//  CategoryTopStories+CoreDataProperties.swift
//  TableViewGuide_RESTAPI
//
//  Created by Nguyễn Thịnh on 04/05/2023.
//
//

import Foundation
import CoreData


extension CategoryTopStories {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CategoryTopStories> {
        return NSFetchRequest<CategoryTopStories>(entityName: "CategoryTopStories")
    }

    @NSManaged public var title: String?
    @NSManaged public var isBookmark: Bool

}

extension CategoryTopStories : Identifiable {

}
