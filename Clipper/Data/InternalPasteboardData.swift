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
}

extension Set where Element : Saveable {
    func saved(_ cond : Bool) -> Set {
        if cond {
            return self.filter { elem in
                elem.saved
            }
        }
        return self
    }
}

extension URL {
    var isImage : Bool {
        switch self.pathExtension {
        case "png":
            return true
        case "jpg":
            return true
        case "jpeg":
            return true
        default:
            return false
        }
    }
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
            let newPasteboardItem = PasteboardData(entryReference: item, id: item.wrappedID, name: item.wrappedName, type: item.wrappedType, data: item.wrappedData, rawData: item.wrappedRawData, date: item.wrappedDate)
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
        self.date = Date.now
        self.entryReference = nil
    }
    
    init(entryReference : Entry, id : UUID, name : String, type : Int16, data : Any, rawData : Data, date : Date) {
        self.id = id
        self.saved = true
        self.name = name
        self.type = PasteboardType(rawValue: type)!
        self.data = data
        self.rawData = rawData
        self.date = date
        self.entryReference = entryReference
    }
    
}


//Function that access system-wide pasteboard and returns tuple where tuple[0] is
//the type and tuple[1] is the data (conforms to Any)
//OPTIONAL --> If no data is found or there is an error, returns nil
func readData(from pasteboard : NSPasteboard) -> (PasteboardType, Any, Data)? {
    //resolve type
    if let items = pasteboard.pasteboardItems {
        for item in items {
            for type in item.types {
                switch type {
                case NSPasteboard.PasteboardType.URL:
                    print("URL")
                case NSPasteboard.PasteboardType.color:
                    print("Color")
                case NSPasteboard.PasteboardType.fileContents:
                    print("File Contents")
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
                    print("Find panel")
                case NSPasteboard.PasteboardType.font:
                    print("Font Info")
                case NSPasteboard.PasteboardType.html:
                    print("HTML Info")
                case NSPasteboard.PasteboardType.multipleTextSelection:
                    print("Multi-Text")
                case NSPasteboard.PasteboardType.pdf:
                    print("PDF data")
                case NSPasteboard.PasteboardType.png:
                    guard let data = pasteboard.data(forType: .png) else {return nil}
                    return (PasteboardType.png, ["Name" : "Screenshot", "File" : NSImage(data: data) as Any], NSData(data: data)) as? (PasteboardType, Any, Data)
                case NSPasteboard.PasteboardType.rtf:
                    print("RTF Data is covered under rtfd")
                case NSPasteboard.PasteboardType.rtfd://images + string
                    guard let data = pasteboard.data(forType: .rtfd) else {return nil}
                    return (PasteboardType.rtfd, NSAttributedString(rtfd: data, documentAttributes: nil)?.string, NSData(data: data)) as? (PasteboardType, Any, Data) ?? nil
                case NSPasteboard.PasteboardType.ruler:
                    print("Ruler data")
                case NSPasteboard.PasteboardType.sound:
                    print("Sound Data")
                case NSPasteboard.PasteboardType.string:
                    guard let data = pasteboard.data(forType: .string) else {return nil}
                    return (PasteboardType.text, String(data: data, encoding: .utf8), NSData(data: data)) as? (PasteboardType, Any, Data) ?? nil
                case NSPasteboard.PasteboardType.tabularText:
                    print("Tab Text Data")
                case NSPasteboard.PasteboardType.textFinderOptions:
                    print("Text Finder")
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
