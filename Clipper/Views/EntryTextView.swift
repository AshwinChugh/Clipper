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
    @State private var showCategories = false
    @State private var showCategoryAssigner = false
    @State private var alertMessage = "Error"
    @State private var selectedCategory = ""
    @State private var disableCategoryInfo = true
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var categories : FetchedResults<Category>
    
    @ObservedObject var data : PasteboardData
    
    
    var body : some View {
        ZStack(alignment: .topTrailing) {
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
                EntryOptionView(data: self.data, PB: self.PB)
                    .environment(\.managedObjectContext, self.moc)
                
                if (showCategories) {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(self.data.categories.sorted(), id: \.self) { category in
                                CategoryView(category)
                                    .onTapGesture(count: 3) {
                                        withAnimation(.easeOut) {
                                            self.data.categories.remove(category)
                                            self.disableCategoryInfo = self.data.categories.isEmpty
                                            if self.disableCategoryInfo {
                                                self.showCategories.toggle()
                                            }
                                        }
                                        if self.data.saved {
                                            self.data.deleteSaved(self.moc)
                                            self.data.saveItem(self.moc)
                                            if moc.hasChanges {
                                                try? moc.save()
                                            }
                                        }
                                    }
                            }
                        }
                    }
                    .padding(.bottom, 5)
                }
                
                if (showCategoryAssigner) {
                    CategoryAssignerView(selectedCategory: self.$selectedCategory, categories: self.categories, data: self.data) {
                        if self.selectedCategory.isEmpty {
                            self.alertMessage = "Invalid category selected;"
                            self.showingAlert = true
                            return
                        }
                        guard let targetCategory = self.categories.first(where: { value in
                            value.wrappedName == self.selectedCategory
                        }) else {print("Error in finding category"); return}
                        self.data.categories.insert(targetCategory)
                        self.disableCategoryInfo = self.data.categories.isEmpty
                        
                        if (self.data.saved) {
                            self.data.deleteSaved(self.moc)
                            self.data.saveItem(self.moc)
                        }
                        withAnimation(.easeOut) {
                            showCategoryAssigner.toggle()
                        }
                    }
                }
                
            }
            .frame(maxWidth: 390)
            .bAlert("Error", isPresented: $showingAlert) {
                Button("Ok") {}
            } message: {
                Text(alertMessage)
            }
            
            HStack {
                Button {
                    if self.showCategories {
                        withAnimation(.easeIn) {
                            self.showCategories.toggle()
                        }
                    }
                    if self.showCategoryAssigner {
                        withAnimation(.easeOut) {
                            self.showCategoryAssigner.toggle()
                        }
                    } else {
                        withAnimation(.easeIn) {
                            self.showCategoryAssigner.toggle()
                        }
                    }
                } label: {
                    Image(systemName: "plus")
                        .imageScale(.large)
                }
                .buttonStyle(.plain)
                .offset(x: 2, y: 3)
                .disabled(self.categories.isEmpty)
                
                
                Spacer()
                
                CategoryButton(data: self.data) {
                    if (self.showCategoryAssigner) {
                        withAnimation(.easeIn) {
                            self.showCategoryAssigner.toggle()
                        }
                    }
                    if (self.showCategories) {
                        withAnimation(.easeOut) {
                            self.showCategories.toggle()
                        }
                    } else {
                        withAnimation(.easeIn) {
                            self.showCategories.toggle()
                        }
                    }
                }
                .disabled(self.disableCategoryInfo)
            }
        }.onAppear {
            self.disableCategoryInfo = self.data.categories.isEmpty
        }
        .onChange(of: self.data.categories) {_ in
            self.disableCategoryInfo = self.data.categories.isEmpty
        }
    }
    
}
