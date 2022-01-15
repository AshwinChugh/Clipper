//
//  EntryTextView.swift
//  Clipper
//
//  Created by Ashwin Chugh on 1/11/22.
//

import SwiftUI

struct EntryTextView: View {
    @ObservedObject var PB : PasteboardHistory
    @State private var showingAlert = false
    @State private var alertMessage = "Error"
    @Environment(\.managedObjectContext) var moc
    
    @ObservedObject var data : PasteboardData
    
    var body : some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack {
                    Image(systemName: "text.quote")
                        .resizable()
                        .scaledToFit()
                        .frame(minWidth: 20, idealWidth: 20, maxWidth: 60, minHeight: 20, idealHeight: 20, maxHeight: 60)
                        .padding(.top)
                    Text(data.type == .text ? "Copied Text" : "Copied Text/Image(s)")
                        .font(.headline)
                        .padding(.horizontal)
                    Text(data.date, style: .date)
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                        .padding(.horizontal)
                }
                Spacer()
                VStack(alignment: .center) {
                    Spacer()
                    Text(data.data as? String ?? "--Data Error--")
                        .multilineTextAlignment(.center)
                        .lineLimit(5)
                        .foregroundColor(.black)
                        .font(.title3.bold())
                    Spacer()
                }
                Spacer()
            }
            EntryOptionView(data: self.data, PB: self.PB) {
                saveItem()
            } deleteSaved: {
                deleteSaved()
            }
        }
        .frame(maxWidth: 390)
        .bAlert("Error", isPresented: $showingAlert) {
            Button("Ok") {}
        } message: {
            Text(alertMessage)
        }
    }
    
    func deleteSaved() -> Void {
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
        let strData = data.data as? String ?? "--Data Error--"
        cdData.data = Data(strData.utf8)
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
