//
//  TopStories+CoreDataProperties.swift
//  TableViewGuide_RESTAPI
//
//  Created by Nguyễn Thịnh on 04/04/2023.
//
//

import Foundation
import CoreData


extension TopStories {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TopStories> {
        return NSFetchRequest<TopStories>(entityName: "TopStories")
    }

    @NSManaged public var imagesURL: String?
    @NSManaged public var titles: String?

}

extension TopStories : Identifiable {

}
