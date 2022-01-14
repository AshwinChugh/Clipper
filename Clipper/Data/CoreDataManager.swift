//
//  CoreDataManager.swift
//  Clipper
//
//  Created by Ashwin Chugh on 1/12/22.
//

import Foundation
import CoreData

class CoreDataManager : ObservableObject {
    static var container = NSPersistentContainer(name: "ClipperData")
    static var initialized = false
    @Published var context : NSPersistentContainer
    
    init() {
        context = Self.container
        if !Self.initialized {
            Self.container.loadPersistentStores { description, error in
                if let error = error {
                    print("Core Data Failed to Initialize: \(error.localizedDescription)")
                    fatalError()
                }
            }
            Self.initialized = true
        }
    }
}
