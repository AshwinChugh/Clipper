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
    @State private var showNewCategory = false
    @State private var showDeleteCategory = false
    @State private var selectedCategory : Category? = nil
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var savedItems : FetchedResults<Entry>
    @FetchRequest(sortDescriptors: []) var categories : FetchedResults<Category>
    
    let fetchTimer = Timer.publish(every: 1, tolerance: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack {
                Text("Clipper")
                    .font(.title.bold())
                    .padding([.top, .leading, .bottom])
                Text("( v2.0.0 )")
                    .font(.title3)
                    .fontWeight(.thin)
                    .padding([.top, .bottom])
                Spacer()
                
                Button {
                    withAnimation {
                        showSaved.toggle()
                    }
                } label: {
                    VStack(spacing: 1) {
                        Image(systemName: showSaved ? "star.fill" : "star")
                            .imageScale(.large)
                        Text("Saved")
                            .font(.footnote)
                            .fixedSize()
                    }
                }
                .foregroundColor(.orange)
                .frame(width: 15, height: 15)
                .buttonStyle(.plain)
                .padding(.trailing)
                
                Button {
                    withAnimation(.easeOut) {
                        for elem in self.PB.history {
                            if !elem.saved {
                                self.PB.history.remove(elem);
                            }
                        }
                    }
                    NSPasteboard.general.clearContents()
                } label: {
                    VStack(spacing: 1) {
                        Image(systemName: "trash.fill")
                            .imageScale(.large)
                        Text("Clear")
                            .font(.footnote)
                            .fixedSize()
                    }
                }
                .foregroundColor(.red)
                .frame(width: 15, height: 15)
                .buttonStyle(.plain)
                .padding(.trailing)
            }
            if selectedCategory == nil {
                HStack {
                    ScrollView(.horizontal) {
                        LazyHStack {
                            ForEach(self.categories.sorted(by: <), id: \.name) { value in
                                Button {
                                    withAnimation(.default) {
                                        self.selectedCategory = value
                                    }
                                } label: {
                                    CategoryView(value)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    Button {
                        withAnimation(.easeIn) {
                            self.showNewCategory.toggle()
                        }
                    } label: {
                        Image(systemName: "plus.circle")
                            .imageScale(.large)
                    }
                    .buttonStyle(.plain)
                    Button {
                        withAnimation(.easeIn) {
                            self.showDeleteCategory.toggle()
                        }
                    } label: {
                        Image(systemName: "minus.circle")
                            .imageScale(.large)
                    }
                    .disabled(self.categories.isEmpty)
                    .buttonStyle(.plain)
                }
                .frame(maxHeight: 25)
                .padding(.bottom, 5)
                .padding(.horizontal)
            } else {
                HStack(alignment: .center) {
                    Button {
                        withAnimation(.default) {
                            self.selectedCategory = nil
                        }
                    } label: {
                        CategoryView(self.selectedCategory!)
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxHeight: 25)
                .padding(.bottom, 5)
                .padding(.horizontal)
            }
            
            if (self.showNewCategory) {
                AddCategoryView() {
                    withAnimation(.easeOut) {
                        self.showNewCategory.toggle();
                    }
                }
                .onAppear {
                    if (self.showDeleteCategory) {
                        withAnimation(.easeOut) {
                            self.showDeleteCategory.toggle()
                        }
                    }
                }
                .environment(\.managedObjectContext, self.moc)
            }
            if (self.showDeleteCategory) {
                RemoveCategoryView() {
                    withAnimation(.easeOut) {
                        self.showDeleteCategory.toggle();
                    }
                } finalAction: { category in
                    for pbItem in self.PB.history {
                        if pbItem.categories.remove(category) != nil {
                            if pbItem.saved {
                                pbItem.deleteSaved(self.moc)
                                pbItem.saveItem(self.moc)
                            }
                        }
                    }
                }
                .onAppear {
                    if (self.showNewCategory) {
                        withAnimation(.easeOut) {
                            self.showNewCategory.toggle()
                        }
                    }
                }
                .environment(\.managedObjectContext, self.moc)
            }
            
            ScrollView {
                LazyVStack {
                    ForEach(PB.history.saved(showSaved, from: self.selectedCategory).sorted(by: >)) { elem in
                        EntryView(PBH: PB, data: elem)
                            .padding(.horizontal)
                            .environment(\.managedObjectContext, self.moc)
                    }
                }
                .padding(.bottom)
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
