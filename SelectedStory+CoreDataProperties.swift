//
//  SelectedStory+CoreDataProperties.swift
//  TableViewGuide_RESTAPI
//
//  Created by Nguyễn Thịnh on 19/04/2023.
//
//

import Foundation
import CoreData


extension SelectedStory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SelectedStory> {
        return NSFetchRequest<SelectedStory>(entityName: "SelectedStory")
    }

    @NSManaged public var title: String?

}

extension SelectedStory : Identifiable {

}
