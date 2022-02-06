//
//  Category.swift
//  Clipper
//
//  Created by Ashwin Chugh on 1/23/22.
//

import Foundation
import SwiftUI

struct CategoryView : View {
    let obj : Category
    init(_ input : Category) {
        self.obj = input
    }
    var body : some View {
        Text(obj.wrappedName.formatted())
            .foregroundColor(.PurpleMountainMajesty)
            .fontWeight(.regular) //make bold if category is selected, regular otherwise
            .frame(minWidth: 50, maxHeight: 10)
            .padding(5)
            .overlay(
                Capsule()
                    .stroke(Color.PurpleMountainMajesty, lineWidth: 2) //make linewidth 3 if selected, 1 otherwise
            )
            .padding(1)
            .background(Capsule().fill(Color.black))
            .padding(.leading, 5)
    }
}
