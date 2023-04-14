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

    @NSManaged public var imagesURL: String?
    @NSManaged public var title: String?

}

extension TopStory : Identifiable {

}
