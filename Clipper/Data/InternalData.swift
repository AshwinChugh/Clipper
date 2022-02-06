//
//  InternalPasteboardData.swift
//  Clipper
//
//  Created by Ashwin Chugh on 1/11/22.
//

import Foundation
import SwiftUI


protocol Saveable : Hashable {
    var saved : Bool { get set }
    var categories : Set<Category> { get set }
}

enum PasteboardType : Int16 {
    case text
    case image
    case file
    case tiff
    case rtfd
    case png
}

//Class that stores all recorded pasteboard histories
class PasteboardHistory : ObservableObject {
    @Published var history : Set<PasteboardData>
    
    init() {
        history = Set<PasteboardData>()
        fetchNewData()
    }
    
    func fetchNewData() -> Void {
        if let (type, data, rawData) = readData(from: NSPasteboard.general) {
            var name = "\(type)"
            if type == PasteboardType.image || type == PasteboardType.file {
                if let dict = data as? [String : Any] {
                    name = dict["Name"] as? String ?? "Unknown Name"
                }
            }
            history.insert(PasteboardData(saved: false, name: name, type: type, data: data, rawData: rawData))
        }
    }
    
    func loadSavedData(_ savedItems : FetchedResults<Entry>) -> Void {
        for item in savedItems {
            let newPasteboardItem = PasteboardData(entryReference: item, id: item.wrappedID, name: item.wrappedName, type: item.wrappedType, data: item.wrappedData, rawData: item.wrappedRawData, date: item.wrappedDate, categories: item.wrappedCategories)
            let (inserted, _) = history.insert(newPasteboardItem)
            if !inserted {
                history.remove(newPasteboardItem)
                history.insert(newPasteboardItem)
            }
        }
    }
}

//Internal pasteboard data that is stored in PasteboardHistory
class PasteboardData : Hashable, Identifiable, Comparable, Saveable, ObservableObject {
    @Published var saved: Bool
    @Published var entryReference : Entry?
    @Published var categories : Set<Category>
    
    let id : UUID
    let name : String
    let type : PasteboardType
    let data : Any
    let rawData : Data
    let date : Date
    
    static func < (lhs: PasteboardData, rhs: PasteboardData) -> Bool {
        lhs.date < rhs.date
    }
    
    static func == (lhs: PasteboardData, rhs: PasteboardData) -> Bool {
        lhs.name == rhs.name &&
        lhs.type == rhs.type &&
        lhs.rawData == rhs.rawData
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(type)
        hasher.combine(rawData)
    }
    
    init(saved : Bool, name : String, type : PasteboardType, data : Any, rawData : Data) {
        self.id = UUID()
        self.saved = saved
        self.name = name
        self.type = type
        self.data = data
        self.rawData = rawData
        if #available(macOS 12, *) {
            self.date = Date.now
        } else {
            self.date = Date()
        }
        self.entryReference = nil
        self.categories = []
    }
    
    init(entryReference : Entry, id : UUID, name : String, type : Int16, data : Any, rawData : Data, date : Date, categories : Set<Category>) {
        self.id = id
        self.saved = true
        self.name = name
        self.type = PasteboardType(rawValue: type)!
        self.data = data
        self.rawData = rawData
        self.date = date
        self.entryReference = entryReference
        self.categories = categories
    }
    
    func deleteSaved(_ moc : NSManagedObjectContext) -> Void {
        moc.delete(self.entryReference!)
        if moc.hasChanges {
            do {
                try moc.save()
                self.entryReference = nil
            } catch {
                print("Could not delete entry")
            }
        }
    }

    func saveItem(_ moc : NSManagedObjectContext) -> Void {
        let cdData = Entry(context: moc)
        cdData.id = self.id
        cdData.name = self.name
        if self.type == .file {
            let fileName = (self.data as! [String : Any])["Name"] as? String ?? "--File Name Error--"
            cdData.data = Data(fileName.utf8)
        } else if self.type == .text || self.type == .rtfd {
            let strData = self.data as? String ?? "--Data Error--"
            cdData.data = Data(strData.utf8)
        } else {
            let imageName = (self.data as! [String : Any])["Name"] as? String ?? "--Image Name Err--"
            cdData.data = Data(imageName.utf8)
        }
        cdData.rawData = self.rawData
        cdData.date = self.date
        cdData.type = self.type.rawValue
        cdData.category = NSSet(set: self.categories)
        
        self.entryReference = cdData
        if moc.hasChanges {
            do {
                try moc.save()
            } catch {
                print("Could not save: \(error)")
            }
        }
    }
    
}


/*
 Function that access system-wide pasteboard and returns tuple where tuple[0] is
 the type and tuple[1] is the data (conforms to Any)
 OPTIONAL --> If no data is found or there is an error, returns nil
 Many options have not been implemented and this is a current limitation of Clipper.
 These options have been left here for those who know how they work and want to provide
 functionality to them.
*/
func readData(from pasteboard : NSPasteboard) -> (PasteboardType, Any, Data)? {
    if let items = pasteboard.pasteboardItems {
        for item in items {
            for type in item.types {
                switch type {
                case NSPasteboard.PasteboardType.URL:
                    break
                case NSPasteboard.PasteboardType.color:
                    break
                case NSPasteboard.PasteboardType.fileContents:
                    break
                case NSPasteboard.PasteboardType.fileURL:
                    if let fileData = pasteboard.data(forType: .fileURL) {
                        guard let strURL = String(data: fileData, encoding: .utf8) else {return nil}
                        let url = URL(string: strURL)!
                        guard let data = pasteboard.data(forType: .string) else {return nil}
                        let name = String(data: data, encoding: .utf8)
                        let imageArr : [String : Any] = ["Name" : name!, "File" : url.isImage ? NSImage(byReferencing: url) : url]
                        return (url.isImage ? PasteboardType.image : PasteboardType.file, imageArr, NSData(data: fileData)) as? (PasteboardType, Any, Data)
                    }
                case NSPasteboard.PasteboardType.findPanelSearchOptions:
                    break
                case NSPasteboard.PasteboardType.font:
                    break
                case NSPasteboard.PasteboardType.html:
                    break
                case NSPasteboard.PasteboardType.multipleTextSelection:
                    break
                case NSPasteboard.PasteboardType.pdf:
                    break
                case NSPasteboard.PasteboardType.png:
                    guard let data = pasteboard.data(forType: .png) else {return nil}
                    return (PasteboardType.png, ["Name" : "Screenshot", "File" : NSImage(data: data) as Any], NSData(data: data)) as? (PasteboardType, Any, Data)
                case NSPasteboard.PasteboardType.rtf:
                    break //this should never be implemented -- RTF data is RTFD data as well
                case NSPasteboard.PasteboardType.rtfd:
                    guard let data = pasteboard.data(forType: .rtfd) else {return nil}
                    return (PasteboardType.rtfd, NSAttributedString(rtfd: data, documentAttributes: nil)?.string, NSData(data: data)) as? (PasteboardType, Any, Data) ?? nil
                case NSPasteboard.PasteboardType.ruler:
                    break
                case NSPasteboard.PasteboardType.sound:
                    break
                case NSPasteboard.PasteboardType.string:
                    guard let data = pasteboard.data(forType: .string) else {return nil}
                    return (PasteboardType.text, String(data: data, encoding: .utf8), NSData(data: data)) as? (PasteboardType, Any, Data) ?? nil
                case NSPasteboard.PasteboardType.tabularText:
                    break
                case NSPasteboard.PasteboardType.textFinderOptions:
                    break
                case NSPasteboard.PasteboardType.tiff:
                    guard let data = pasteboard.data(forType: .tiff) else {return nil}
                    return (PasteboardType.tiff, ["Name" : "<Anonymous Image>", "File" : NSImage(data: data) as Any], NSData(data: data)) as? (PasteboardType, Any, Data) ?? nil
                default:
                    break
                }
            }
        }
    }
    return nil
}
