//
//  CompatibilityExtensions.swift
//  Clipper
//
//  Created by Ashwin Chugh on 1/15/22.
//

import Foundation
import SwiftUI


extension View {
    
    @ViewBuilder
    func bAlert<S, A, M>(_ title : S, isPresented: Binding<Bool>, actions: () -> A, message: () -> M) -> some View where S : StringProtocol, A : View, M : View {
        if #available(macOS 12, *) {
            self.alert(title, isPresented: isPresented) {
                actions()
            } message: {
                message()
            }
        } else {
            self.alert(isPresented: isPresented) {
                Alert(
                    title: Text(title),
                    message: message() as? Text ?? Text("Something went wrong in displaying the alert message.")
                )
            }
        }
    }
}
