//
//  RemoveCategoryView.swift
//  Clipper
//
//  Created by Ashwin Chugh on 1/23/22.
//

import SwiftUI

struct RemoveCategoryView: View {
    @State private var selectedCategory = ""
    @FetchRequest(sortDescriptors: []) var categories : FetchedResults<Category>
    @Environment(\.managedObjectContext) var moc
    
    var dismiss : () -> Void
    var finalAction : (Category) -> Void
    
    var body: some View {
        VStack {
            Text("Select a category to remove.")
            Text("This will remove the category from all copied items with this cateogory.")
                .font(.caption)
            Picker("Category", selection: self.$selectedCategory) {
                ForEach(self.categories) { value in
                    Text(value.wrappedName).tag(value.wrappedName)
                }
            }
            HStack {
                Button {
                    guard let category = self.categories.first(where: {curr in
                        curr.wrappedName == self.selectedCategory
                    }) else {return}
                    finalAction(category)
                    moc.delete(category)
                    if moc.hasChanges {
                        try? moc.save()
                    }
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "trash")
                            .imageScale(.large)
                        Text("Delete Category")
                    }
                    .foregroundColor(.VioletBlueCrayola)
                    .padding(5)
                }
                .buttonStyle(.plain)
                .background(Color.EerieBlack)
                .clipShape(RoundedRectangle(cornerRadius: 3))
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .foregroundColor(.LightGray)
                        .padding(8)
                }
                .buttonStyle(.plain)
                .background(Color.EerieBlack)
                .clipShape(RoundedRectangle(cornerRadius: 3))
            }
        }
        .padding()
        .frame(minWidth: 200, minHeight: 100)
    }
}
