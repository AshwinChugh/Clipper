//
//  Entry+CoreDataProperties.swift
//  Clipper
//
//  Created by Ashwin Chugh on 1/22/22.
//
//

import Foundation
import CoreData
import SwiftUI


extension Entry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entry> {
        return NSFetchRequest<Entry>(entityName: "Entry")
    }

    @NSManaged public var data: Data?
    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var rawData: Data?
    @NSManaged public var type: Int16
    @NSManaged public var category: NSSet?
    
    public var wrappedID : UUID {
        return id ?? UUID()
    }
        
    public var wrappedName : String {
        return self.name ?? "Unknown Name"
    }
    
    public var wrappedData : Any {
        switch PasteboardType(rawValue: self.type) {
        case .text:
            return String(data: self.wrappedRawData, encoding: .utf8) ?? "Data Error"
        case .rtfd:
            return NSAttributedString(rtfd: self.wrappedRawData, documentAttributes: nil)!.string as Any
        case .file:
            fallthrough
        case .image:
            let strURL = String(data: self.wrappedRawData, encoding: .utf8)!
            let url = URL(string: strURL)!
            let retArr : [String : Any] = ["Name" : String(data: self.data!, encoding: .utf8) as Any, "File" : url.isImage ? NSImage(byReferencing: url) : url]
            return retArr
        case .tiff:
            return ["Name" : "<Anonymous Image>", "File" : NSImage(data: self.wrappedRawData) as Any]
        case .png:
            return ["Name" : "Screenshot", "File" : NSImage(data: self.wrappedRawData) as Any]
        default:
            fatalError("Data was corrupted")
        }
    }
    
    public var wrappedRawData : Data {
        return self.rawData!
    }
    
    public var wrappedDate : Date {
        if #available(macOS 12, *) {
            return self.date ?? Date.now
        } else {
            return self.date ?? Date()
        }
    }
    
    public var wrappedType : Int16 {
        return self.type
    }
    
    public var wrappedCategories : Set<Category> {
        return self.category as? Set<Category> ?? []
    }

}

// MARK: Generated accessors for category
extension Entry {

    @objc(addCategoryObject:)
    @NSManaged public func addToCategory(_ value: Category)

    @objc(removeCategoryObject:)
    @NSManaged public func removeFromCategory(_ value: Category)

    @objc(addCategory:)
    @NSManaged public func addToCategory(_ values: NSSet)

    @objc(removeCategory:)
    @NSManaged public func removeFromCategory(_ values: NSSet)

}

extension Entry : Identifiable {

}
