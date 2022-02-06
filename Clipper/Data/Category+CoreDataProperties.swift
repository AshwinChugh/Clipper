//
//  Category+CoreDataProperties.swift
//  Clipper
//
//  Created by Ashwin Chugh on 1/22/22.
//
//

import Foundation
import CoreData


extension Category : Comparable {
    public static func < (lhs: Category, rhs: Category) -> Bool {
        return lhs.wrappedDate < rhs.wrappedDate
    }
    

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var name: String?
    @NSManaged public var date: Date?
    @NSManaged public var entries: NSSet?
    
    public var wrappedName : String {
        return self.name ?? "Unknown Category"
    }
    
    public var wrappedEntries : Set<Entry> {
        return self.entries as? Set<Entry> ?? []
    }
    
    public var wrappedDate : Date {
        if #available(macOS 12, *) {
            return self.date ?? Date.now
        } else {
            return self.date ?? Date()
        }
    }
    
    
}

// MARK: Generated accessors for entry
extension Category {

    @objc(addEntryObject:)
    @NSManaged public func addToEntry(_ value: Entry)

    @objc(removeEntryObject:)
    @NSManaged public func removeFromEntry(_ value: Entry)

    @objc(addEntry:)
    @NSManaged public func addToEntry(_ values: NSSet)

    @objc(removeEntry:)
    @NSManaged public func removeFromEntry(_ values: NSSet)

}

extension Category : Identifiable {

}
