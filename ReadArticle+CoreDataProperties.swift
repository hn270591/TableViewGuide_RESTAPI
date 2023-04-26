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
        static let publishMonthID = "publishMonthID"
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReadArticle> {
        return NSFetchRequest<ReadArticle>(entityName: "ReadArticle")
    }

    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var imageURL: String?
    @NSManaged private var primitivePublishDate: Date?
    @NSManaged private var primitivePublishMonthID: String?
    
    class func keyPathsForValuesAffectingPublishMonthID() -> Set<String> {
        return [Name.publishDate]
    }
    
    //
    public var publishDate: Date? {
        get {
            willAccessValue(forKey: Name.publishDate)
            defer { didAccessValue(forKey: Name.publishDate )}
            return primitivePublishDate
        }
        set {
            willAccessValue(forKey: Name.publishDate)
            defer { didAccessValue(forKey: Name.publishDate )}
            primitivePublishDate = newValue
            primitivePublishMonthID = nil
        }
    }
    
    //
    @objc public var publishMonthID: String? {
        get {
            willAccessValue(forKey: Name.publishMonthID)
            defer { didAccessValue(forKey: Name.publishMonthID )}
            
            guard primitivePublishMonthID == nil, let date = primitivePublishDate else {
                return primitivePublishMonthID
            }
            
            let calenar = Calendar(identifier: .gregorian)
            let components = calenar.dateComponents([.year, .month], from: date)
            if let year = components.year, let month = components.month {
                primitivePublishMonthID = "\(year * 1000 + month)"
            }
            return primitivePublishMonthID
        }
    }
    
    class func date(from publishMonthString: String) -> Date? {
        guard let numericSection = Int(publishMonthString) else { return nil }
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar(identifier: .gregorian)
        
        let year = numericSection / 1000
        let month = numericSection - year * 1000
        dateComponents.year = year
        dateComponents.month = month
        
        return dateComponents.calendar?.date(from: dateComponents)
    }

}

extension ReadArticle : Identifiable {

}
