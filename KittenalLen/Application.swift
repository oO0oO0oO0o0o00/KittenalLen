//
//  Application.swift
//  KittenalLen
//
//  Created by MeowCat on 2025/11/30.
//

import SwiftUI
import SwiftData

@main
struct Application {
    static func main() {
        let delegate = AppDelegate()
        NSApplication.shared.delegate = delegate
        NSApplication.shared.run()
    }
}

@MainActor
private class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private var sharedModels = ModelContainer()
    
    private var settingsWindow: NSWindow?
    
    private var lens: LensHost?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let settings = sharedModels.loadSettings()
        let lens = LensHost(settings: settings)
        self.lens = lens
        if Application.debugSettingsUI {
            settings.isFirstLaunch = true
            showSettings(with: lens)
        } else if settings.isFirstLaunch {
            settings.isFirstLaunch = false
            showSettings(with: lens)
        }
    }
    
    func applicationWillEnterForeground(_ notification: Notification) {
        guard let lens = lens,
              settingsWindow == nil else {
            return
        }
        showSettings(with: lens)
    }
    
    private func showSettings(with lens: LensHost) {
        let window = NSWindow()
        window.contentView = NSHostingView(rootView: SettingsView(
            settings: lens.settings))
        window.title = "🐱 Settings"
        window.styleMask.insert(.closable)
        window.delegate = self
        window.isReleasedWhenClosed = false
        window.center()
        window.makeKeyAndOrderFront(self)
        settingsWindow = window
    }
    
    func applicationShouldHandleReopen(
        _ sender: NSApplication, hasVisibleWindows: Bool
    ) -> Bool {
        true
    }
    
    func windowWillClose(_ notification: Notification) {
        settingsWindow = nil
    }
}
