//
//  AddCategoryView.swift
//  Clipper
//
//  Created by Ashwin Chugh on 1/23/22.
//

import SwiftUI

struct AddCategoryView: View {
    @State private var category = ""
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var showAlert = false
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var categories : FetchedResults<Category>
    
    var dismiss : () -> Void
    
    var body: some View {
        VStack {
            Text("Create a Category")
                .font(.title3)
            TextField("Category Name", text: self.$category)
                .textFieldStyle(.plain)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.PurpleMountainMajesty, lineWidth: 2)
                )
                .foregroundColor(.PurpleMountainMajesty)
            HStack {
                Button {
                    if self.category.isEmpty {
                        self.alertTitle = "Category Naming Error"
                        self.alertMessage = "Category name can not be blank"
                        showAlert = true
                        return
                    }
                    for elem in self.categories {
                        if elem.wrappedName == self.category.formatted() {
                            self.alertMessage = "The category name needs to be unique."
                            self.showAlert = true
                            return
                        }
                    }
                    let newCategory = Category(context: moc)
                    newCategory.name = self.category.formatted()
                    if #available(macOS 12, *) {
                        newCategory.date = Date.now
                    } else {
                        newCategory.date = Date()
                    }
                    if moc.hasChanges {
                        try? moc.save()
                    }
                    dismiss()
                } label: {
                    Text("Add Category")
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
                        .padding(5)
                }
                .buttonStyle(.plain)
                .background(Color.EerieBlack)
                .clipShape(RoundedRectangle(cornerRadius: 3))
            }
        }
        .bAlert(self.alertTitle, isPresented: self.$showAlert) {
            Button("Ok") {}
        } message: {
            Text(self.alertMessage)
        }
        .padding([.leading, .trailing, .bottom])
        .frame(minWidth: 200, minHeight: 100)
    }
}

struct AddCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        AddCategoryView() {}
    }
}
