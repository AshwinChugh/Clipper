//
//  EntryOptionView.swift
//  Clipper
//
//  Created by Ashwin Chugh on 1/13/22.
//

import SwiftUI

struct EntryOptionView: View {
    @ObservedObject var data : PasteboardData
    @ObservedObject var PB : PasteboardHistory
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    let saveItem : () -> Void
    let deleteSaved : () -> Void
    
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
                    Text("Copy")
                        .fixedSize()
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                .foregroundColor(.green)
            }
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
                    saveItem()
                } else {
                    deleteSaved()
                }
            } label: {
                HStack {
                    Image(systemName: data.saved ? "star.fill" : "star")
                    Text("Save")
                        .fixedSize()
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                .foregroundColor(.orange)
            }
            .buttonStyle(.plain)
            .background(Color.black)
            .clipShape(Capsule())
            
            Spacer()
            
            Button {
                PB.history.remove(data)
                if data.saved {
                    deleteSaved()
                }
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete")
                        .fixedSize()
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                .foregroundColor(.red)
            }
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
        EntryOptionView(data: PasteboardData(saved: false, name: "Sample Data", type: .file, data: dict, rawData: NSData(data: (NSImage(systemSymbolName: "app", accessibilityDescription: "app image")?.tiffRepresentation)!) as Data), PB: PasteboardHistory()) {
            return
        } deleteSaved : {
            return
        }
    }
}
