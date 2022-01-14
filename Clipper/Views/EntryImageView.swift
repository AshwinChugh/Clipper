//
//  EntryImageView.swift
//  Clipper
//
//  Created by Ashwin Chugh on 1/11/22.
//

import SwiftUI

struct EntryImageView: View {
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var PB : PasteboardHistory
    @ObservedObject var data : PasteboardData
    @State var isSaved = false
    @State var showingAlert = false
    
    let image : NSImage
    let imageName : String
    
    init(PB : PasteboardHistory, data : PasteboardData) {
        self.PB = PB
        self.data = data
        if let dict = data.data as? [String : Any] {
            image = dict["File"] as? NSImage ?? NSImage(systemSymbolName: "exclamationmark.circle", accessibilityDescription: "Error Image Placeholder")!
            imageName = dict["Name"] as? String ?? "Image Name Error"
        } else {
            image = NSImage(systemSymbolName: "exclamationmark.circle", accessibilityDescription: "Error Image Placeholder")!
            imageName = "Image Error"
        }
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Image(nsImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 350, maxHeight: 350)
                .padding(.top)
            Text(imageName)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .font(.title.bold())
            Text("Copied Image")
                .font(.headline)
                .multilineTextAlignment(.center)
            Text(data.date, style: .date)
            EntryOptionView(data: self.data, PB: self.PB) {
                saveItem()
            } deleteSaved: {
                deleteSave()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert("Error", isPresented: $showingAlert) {
            Button("Ok") {}
        } message: {
            Text("Could not copy Image to clipboard.")
        }
    }
    
    func saveItem() -> Void {
        let cdData = Entry(context: moc)
        cdData.id = data.id
        cdData.name = data.name
        cdData.data = Data(self.imageName.utf8)
        cdData.rawData = data.rawData
        cdData.date = data.date
        cdData.type = data.type.rawValue
        
        data.entryReference = cdData
        if moc.hasChanges {
            do {
                try moc.save()
                print("Entry saved")
            } catch {
                print("Could not save: \(error)")
            }
        }
    }
    
    func deleteSave() -> Void {
        guard let entry = data.entryReference else {
            print("Could not delete item from Core Data -- reference lost.")
            return
        }
        moc.delete(entry)
        if moc.hasChanges {
            do {
                try moc.save()
                data.entryReference = nil
                print("Entry deleted")
            } catch {
                print("Could not delete entry")
            }
        }
    }
}

struct EntryImageView_Previews: PreviewProvider {
    static var dict : [String : Any] = [
        "Name" : "App.png",
        "File" : NSImage(systemSymbolName: "app", accessibilityDescription: "app image")!
    ]
    
    static var previews: some View {
        EntryImageView(PB: PasteboardHistory(), data: PasteboardData(saved: false, name: "Sample Data", type: .file, data: dict, rawData: NSData(data: (NSImage(systemSymbolName: "app", accessibilityDescription: "app image")?.tiffRepresentation)!) as Data))
    }
}
