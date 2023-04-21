//
//  TopStories+CoreDataProperties.swift
//  TableViewGuide_RESTAPI
//
//  Created by Nguyễn Thịnh on 04/04/2023.
//
//

import Foundation
import CoreData

extension TopStory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TopStory> {
        return NSFetchRequest<TopStory>(entityName: "TopStory")
    }

    @NSManaged public var imageURL: String?
    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var isRead: Bool

}

extension TopStory : Identifiable {

}
