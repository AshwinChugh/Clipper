//
//  CategoryButton.swift
//  Clipper
//
//  Created by Ashwin Chugh on 1/23/22.
//

import SwiftUI

struct CategoryButton: View {
    @ObservedObject var data : PasteboardData
    var action : () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "info.circle")
                .foregroundColor(.PurpleMountainMajesty.opacity(2.0))
                .imageScale(.large)
        }
        .offset(x: -2, y: 3)
        .buttonStyle(.plain)
    }
}
