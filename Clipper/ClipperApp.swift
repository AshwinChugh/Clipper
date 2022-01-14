//
//  ClipperApp.swift
//  Clipper
//
//  Created by Ashwin Chugh on 1/9/22.
//

import SwiftUI
import CloudKit

@main
struct ClipperApp: App {
    @StateObject var coreDataManager = CoreDataManager()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, coreDataManager.context.viewContext)
        }
    }
}
