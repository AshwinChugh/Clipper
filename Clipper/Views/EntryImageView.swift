//
//  EntryImageView.swift
//  Clipper
//
//  Created by Ashwin Chugh on 1/11/22.
//

import SwiftUI

struct EntryImageView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var categories : FetchedResults<Category>
    @ObservedObject var PB : PasteboardHistory
    @ObservedObject var data : PasteboardData
    @State private var alertMessage = "Error"
    @State private var selectedCategory = ""
    @State private var showCategoryAssigner = false
    @State private var isSaved = false
    @State private var showingAlert = false
    @State private var showCategories = false
    @State private var disableCategoryInfo = true
    
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
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .center) {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 350, maxHeight: 350)
                    .padding(.top)
                Text(imageName)
                    .multilineTextAlignment(.center)
                    .font(.title.bold())
                Text("Copied Image")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                Text(data.date, style: .date)
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .bAlert("Error", isPresented: $showingAlert) {
                Button("Ok") {}
            } message: {
                Text(self.alertMessage)
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

struct EntryImageView_Previews: PreviewProvider {
    static var dict : [String : Any] = [
        "Name" : "App.png",
        "File" : NSImage(systemSymbolName: "app", accessibilityDescription: "app image")!
    ]
    
    static var previews: some View {
        EntryImageView(PB: PasteboardHistory(), data: PasteboardData(saved: false, name: "Sample Data", type: .file, data: dict, rawData: NSData(data: (NSImage(systemSymbolName: "app", accessibilityDescription: "app image")?.tiffRepresentation)!) as Data))
    }
}
