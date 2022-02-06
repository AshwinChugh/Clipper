//
//  CategoryAssignerView.swift
//  Clipper
//
//  Created by Ashwin Chugh on 1/31/22.
//

import SwiftUI

struct CategoryAssignerView: View {
    @Binding var selectedCategory : String
    public var categories : FetchedResults<Category>
    public var data : PasteboardData
    
    let action : () -> Void
    
    var body: some View {
        VStack {
            Picker("Category", selection: self.$selectedCategory) {
                ForEach(self.categories.filter({curr in
                    !self.data.categories.contains(curr)
                })) { value in
                    Text(value.wrappedName).tag(value.wrappedName)
                }
            }
            .padding(.horizontal)
            
            Button {
                action()
            } label: {
                Text("Assign Category")
                .padding(.horizontal)
                .padding(.vertical, 5)
                .foregroundColor(.PurpleMountainMajesty)
            }
            .frame(minWidth: 85, minHeight: 27)
            .buttonStyle(.plain)
            .background(Color.black)
            .clipShape(Capsule())
            .padding(.bottom)
        }
    }
}
