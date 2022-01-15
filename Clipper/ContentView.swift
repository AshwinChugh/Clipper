//
//  ContentView.swift
//  Clipper
//
//  Created by Ashwin Chugh on 1/9/22.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var PB = PasteboardHistory()
    @State private var showSaved = false
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var savedItems : FetchedResults<Entry>
    
    let fetchTimer = Timer.publish(every: 1, tolerance: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Text("Clipper")
                    .font(.title.bold())
                    .padding([.top, .leading, .bottom])
                Text("( Alpha v1.1.1 )")
                    .fontWeight(.thin)
                Spacer()
                
                Button {
                    withAnimation {
                        showSaved.toggle()
                    }
                } label: {
                    Image(systemName: showSaved ? "star.fill" : "star")
                        .resizable()
                        .scaledToFit()
                }
                .foregroundColor(.orange)
                .frame(width: 20, height: 20)
                .buttonStyle(.plain)
                .padding(.trailing)
            }
            ScrollView {
                LazyVStack {
                    ForEach(PB.history.saved(showSaved).sorted(by: >)) {elem in
                        EntryView(PBH: PB, data: elem)
                            .padding(.horizontal)
                            .environment(\.managedObjectContext, self.moc)
                    }
                    
                }
            }
        }
        .background(Color.black)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            PB.loadSavedData(savedItems)
        }
        .onReceive(fetchTimer) { _ in
            withAnimation(.spring()) {
                PB.fetchNewData()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
