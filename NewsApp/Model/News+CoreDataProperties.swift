//
//  News+CoreDataProperties.swift
//  NewsApp
//
//  Created by Maksim Velich on 23.03.21.
//
//

import Foundation
import CoreData


extension News {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<News> {
        return NSFetchRequest<News>(entityName: "News")
    }

    @NSManaged public var image: URL?
    @NSManaged public var isOpen: Bool
    @NSManaged public var newsDescription: String?
    @NSManaged public var title: String?
    @NSManaged public var publishTime: Date?

}

extension News : Identifiable {

}
