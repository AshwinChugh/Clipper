//
//  EntryFileView.swift
//  Clipper
//
//  Created by Ashwin Chugh on 1/11/22.
//

import SwiftUI

struct EntryFileView: View {
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var PB : PasteboardHistory
    @ObservedObject var data : PasteboardData
    @State var isSaved = false
    @State var showingAlert = false
    
    
    var fileName : String {
        if let dict = data.data as? [String : Any] {
            return dict["Name"] as? String ?? "--File Name Error--"
        }
        return "--File Name Error--"
    }
    
    
    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .center) {
                VStack {
                    Image(systemName: "shippingbox")
                        .resizable()
                        .scaledToFit()
                        .frame(minWidth: 20, idealWidth: 40, maxWidth: 60, minHeight: 20, idealHeight: 40, maxHeight: 60)
                        .padding(.top)
                    Text("Copied File")
                        .font(.headline)
                        .padding(.horizontal)
                    Text(data.date, style: .date)
                        .font(.subheadline)
                        .padding(.horizontal)
                }
                Spacer()
                Text(fileName)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .font(.title.bold())
                    .padding(.horizontal)
                Spacer()
            }
            .padding(.top, 5)
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
            Text("Could not copy text to clipboard.")
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
    
    func saveItem() -> Void {
        let cdData = Entry(context: moc)
        cdData.id = data.id
        cdData.name = data.name
        cdData.data = Data(self.fileName.utf8)
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
    
}

struct EntryFileView_Previews: PreviewProvider {
    static var dict : [String : Any] = [
        "Name" : "App.png",
        "File" : NSImage(systemSymbolName: "app", accessibilityDescription: "app image")!
    ]
    
    static var previews: some View {
        EntryFileView(PB: PasteboardHistory(), data: PasteboardData(saved: false, name: "Sample Data", type: .file, data: dict, rawData: NSData(data: (NSImage(systemSymbolName: "app", accessibilityDescription: "app image")?.tiffRepresentation)!) as Data))
    }
}
