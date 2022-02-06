//
//  EntryOptionView.swift
//  Clipper
//
//  Created by Ashwin Chugh on 1/13/22.
//

import SwiftUI

struct EntryOptionView: View {
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var data : PasteboardData
    @ObservedObject var PB : PasteboardHistory
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private var resolvedType : NSPasteboard.PasteboardType {
        let type = data.type
        return type == .text ? .string : type == .rtfd ? .rtfd : type == .file ? .fileURL : type == .image ? .fileURL : type == .tiff ? .tiff : .png
    }
    
    var body: some View {
        HStack {
            Spacer()
            
            Button {
                NSPasteboard.general.clearContents()
                if !NSPasteboard.general.setData(data.rawData, forType: resolvedType) {
                    alertMessage = "Could not copy item to clipboard."
                    showingAlert = true
                }
                NSApp.sendAction(#selector(NSPopover.performClose(_:)), to: nil, from: nil)
            } label: {
                HStack {
                    Image(systemName: "doc.on.doc")
                        .imageScale(.medium)
                    Text("Copy")
                        .fixedSize()
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                .foregroundColor(.green)
            }
            .frame(width: 85, height: 27)
            .buttonStyle(.plain)
            .background(Color.black)
            .clipShape(Capsule())
            
            Spacer()
            
            Button {
                withAnimation {
                    data.saved.toggle()
                    PB.history.remove(data)
                    PB.history.insert(data)
                }
                if data.saved {
                    self.data.saveItem(self.moc)
                } else {
                    self.data.deleteSaved(self.moc)
                }
            } label: {
                HStack {
                    Image(systemName: data.saved ? "star.fill" : "star")
                        .imageScale(.medium)
                    Text("Save")
                        .fixedSize()
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                .foregroundColor(.orange)
            }
            .frame(width: 85, height: 27)
            .buttonStyle(.plain)
            .background(Color.black)
            .clipShape(Capsule())
            
            Spacer()
            
            Button {
                withAnimation(.easeOut) {
                    PB.history.remove(data)
                }
                if data.saved {
                    self.data.deleteSaved(self.moc)
                }
                if data.rawData == PB.history.sorted(by: >).first?.rawData {
                    NSPasteboard.general.clearContents();
                }
            } label: {
                HStack {
                    Image(systemName: "trash")
                        .imageScale(.medium)
                    Text("Delete")
                        .fixedSize()
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                .foregroundColor(.red)
            }
            .frame(width: 85, height: 27)
            .buttonStyle(.plain)
            .background(Color.black)
            .clipShape(Capsule())
            
            Spacer()
        }
        .padding(.bottom)
    }
}

struct EntryOptionView_Previews: PreviewProvider {
    static var dict : [String : Any] = [
        "Name" : "App.png",
        "File" : NSImage(systemSymbolName: "app", accessibilityDescription: "app image")!
    ]
    
    static var previews: some View {
        EntryOptionView(data: PasteboardData(saved: false, name: "Sample Data", type: .file, data: dict, rawData: NSData(data: (NSImage(systemSymbolName: "app", accessibilityDescription: "app image")?.tiffRepresentation)!) as Data), PB: PasteboardHistory())
    }
}
