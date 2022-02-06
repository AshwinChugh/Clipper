//
//  Extensions.swift
//  Clipper
//
//  Created by Ashwin Chugh on 1/23/22.
//

import Foundation
import SwiftUI

extension Set where Element : Saveable {
    /*
     cond - Boolean variable that determines whether or not to show saved items only
     category - Category object that if not nil will only return items that have been
        assigned to that category
     */
    func saved(_ cond : Bool, from category : Category? = nil) -> Set {
        if cond {
            if let category = category {
                return self.filter { elem in
                    elem.saved && elem.categories.contains(category)
                }
            }
            return self.filter { elem in
                elem.saved
            }
        }
        if let category = category {
            return self.filter { elem in
                elem.categories.contains(category)
            }
        }
        return self
    }
}

extension String {
    func formatted() -> String {
        var retStr : String = self.first?.uppercased() ?? "-"
        retStr += self[self.index(after: self.startIndex) ..< self.endIndex].lowercased()
        return retStr
    }
}

extension URL {
    var isImage : Bool {
        switch self.pathExtension {
        case "png":
            return true
        case "jpg":
            return true
        case "jpeg":
            return true
        default:
            return false
        }
    }
}

extension Color {
    static var VioletBlueCrayola : Color {
        Color(red: 0.494118, green: 0.431373, blue: 0.768627)
    }
    
    static var PurpleMountainMajesty : Color {
        Color(red: 0.596078, green: 0.545098, blue: 0.815686)
    }
    
    static var Cultured : Color {
        Color(red: 0.984314, green: 0.980392, blue: 0.972549)
    }
    
    static var Jet : Color {
        Color(red: 0.160748, green: 0.160784, blue: 0.160784)
    }
    
    static var Onyx : Color {
        Color(red: 0.239216, green: 0.239216, blue: 0.239216)
    }
    
    static var EerieBlack : Color {
        Color(red: 0.121569, green: 0.121569, blue: 0.121569)
    }
    
    static var LightGray : Color {
        Color(red: 0.839216, green: 0.839216, blue: 0.839216)
    }
}

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
