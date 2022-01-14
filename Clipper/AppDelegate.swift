//
//  AppDelegate.swift
//  Clipper
//
//  Created by Ashwin Chugh on 1/10/22.
//

import Foundation
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem : NSStatusItem?
    var popOver : NSPopover?
    static var coreDataManager = CoreDataManager()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let contentView = ContentView()
            .environment(\.managedObjectContext, Self.coreDataManager.context.viewContext)
        
        self.popOver = NSPopover()
        popOver!.contentSize = NSSize(width: 400, height: 500)
        popOver!.behavior = .transient
        popOver!.contentViewController = NSHostingController(rootView: contentView)
        
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        
        if let button = self.statusBarItem?.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Clipper Status Bar Button")
            button.action = #selector(togglePopover(_:))
            self.popOver!.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
        
        if let window = NSApplication.shared.windows.first {
            window.close()
        }
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = self.statusBarItem?.button {
            if self.popOver!.isShown {
                self.popOver!.performClose(sender)
            } else {
                self.popOver!.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }
}
