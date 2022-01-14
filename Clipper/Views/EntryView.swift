//
//  EntryView.swift
//  Clipper
//
//  Created by Ashwin Chugh on 1/11/22.
//

import SwiftUI

struct EntryView: View {
    @ObservedObject var PBH : PasteboardHistory
    @StateObject var data : PasteboardData
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        MasterView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.gray)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 10)
    }
    
    @ViewBuilder
    func MasterView() -> some View {
        switch data.type {
        case .text:
            EntryTextView(PB: PBH, data: data)
                .environment(\.managedObjectContext, self.moc)
        case .file:
            EntryFileView(PB: PBH, data: data)
                .environment(\.managedObjectContext, self.moc)
        case .image:
            EntryImageView(PB: PBH, data: data)
                .environment(\.managedObjectContext, self.moc)
        case .tiff:
            EntryImageView(PB: PBH, data: data)
                .environment(\.managedObjectContext, self.moc)
        case .rtfd:
            EntryTextView(PB: PBH, data: data)
                .environment(\.managedObjectContext, self.moc)
        case .png:
            EntryImageView(PB: PBH, data: data)
        }
    }
}

struct EntryView_Previews: PreviewProvider {
    static var previews: some View {
        EntryView(PBH: PasteboardHistory(), data: PasteboardData(saved: false, name: "Sample Data", type: .text, data: "Hello this is a sample string", rawData: NSData(base64Encoded: "Hello this is a sample string")! as Data))
    }
}
