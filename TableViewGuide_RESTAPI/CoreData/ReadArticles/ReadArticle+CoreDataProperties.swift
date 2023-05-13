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
    
    struct Name {
        static let publishDate = "publishDate"
        static let publishDayID = "publishDayID"
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReadArticle> {
        return NSFetchRequest<ReadArticle>(entityName: "ReadArticle")
    }

    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var imageURL: String?
    @NSManaged private var primitivePublishDate: Date?
    @NSManaged private var primitivePublishDayID: String?
    
    class func keyPathsForValuesAffectingPublishDayID() -> Set<String> {
        return [Name.publishDate]
    }
    
    //
    @objc public var publishDate: Date? {
        get {
            willAccessValue(forKey: Name.publishDate)
            defer { didAccessValue(forKey: Name.publishDate )}
            return primitivePublishDate
        }
        set {
            willAccessValue(forKey: Name.publishDate)
            defer { didAccessValue(forKey: Name.publishDate )}
            primitivePublishDate = newValue
            primitivePublishDayID = nil
        }
    }
    
    //
    @objc public var publishDayID: String? {
        get {
            willAccessValue(forKey: Name.publishDayID)
            defer { didAccessValue(forKey: Name.publishDayID )}
            
            guard primitivePublishDayID == nil, let date = primitivePublishDate else {
                return primitivePublishDayID
            }
            
            primitivePublishDayID = DateFormatter.dateFormatterForSectionHeader(date: date)
            return primitivePublishDayID
        }
    }
}

extension ReadArticle : Identifiable {

}
