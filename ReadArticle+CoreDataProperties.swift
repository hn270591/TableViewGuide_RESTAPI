//
//  ReadArticle+CoreDataProperties.swift
//  TableViewGuide_RESTAPI
//
//  Created by Nguyễn Thịnh on 19/04/2023.
//
//

import Foundation
import CoreData


extension ReadArticle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReadArticle> {
        return NSFetchRequest<ReadArticle>(entityName: "ReadArticle")
    }

    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var index: Int32

}

extension ReadArticle : Identifiable {

}
