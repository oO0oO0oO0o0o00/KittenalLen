//
//  Application.swift
//  KittenalLen
//
//  Created by MeowCat on 2025/11/30.
//

import SwiftUI
import SwiftData
import Carbon

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

    private var screenshotHotkey = GlobalHotkeyManager(id: 1)

    private var toggleHotkey = GlobalHotkeyManager(id: 2)

    func applicationDidFinishLaunching(_ notification: Notification) {
        let settings = sharedModels.loadSettings()
        let lens = LensHost(settings: settings)
        self.lens = lens

        screenshotHotkey.onHotkeyPressed = { [weak self] in
            guard let self, let lens = self.lens else { return }
            let duration = TimeInterval(lens.settings.screenshotHideDuration)
            lens.hideTemporarily(duration: duration)
        }
        toggleHotkey.onHotkeyPressed = { [weak self] in
            self?.lens?.toggleEnabled()
        }
        registerScreenshotHotkey(from: settings)
        registerToggleHotkey(from: settings)

        if Application.debugSettingsUI {
            settings.isFirstLaunch = true
            showSettings(with: lens)
        } else if settings.isFirstLaunch {
            settings.isFirstLaunch = false
            showSettings(with: lens)
        }
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        if let lens, settingsWindow == nil {
            showSettings(with: lens)
        }
    }

    private func registerScreenshotHotkey(from settings: Settings) {
        screenshotHotkey.register(
            keyCode: settings.hotkeyKeyCode,
            modifiers: settings.hotkeyModifiers)
    }

    private func registerToggleHotkey(from settings: Settings) {
        toggleHotkey.register(
            keyCode: settings.toggleKeyCode,
            modifiers: settings.toggleModifiers)
    }

    private func showSettings(with lens: LensHost) {
        let window = NSWindow()
        var settingsView = SettingsView(settings: lens.settings)
        settingsView.onScreenshotShortcutChanged = { [weak self] in
            guard let self, let lens = self.lens else { return }
            self.registerScreenshotHotkey(from: lens.settings)
        }
        settingsView.onToggleShortcutChanged = { [weak self] in
            guard let self, let lens = self.lens else { return }
            self.registerToggleHotkey(from: lens.settings)
        }
        settingsView.onRecordingStateChanged = { [weak self] isRecording in
            if isRecording {
                self?.screenshotHotkey.unregister()
                self?.toggleHotkey.unregister()
            } else {
                self?.registerScreenshotHotkey(from: lens.settings)
                self?.registerToggleHotkey(from: lens.settings)
            }
        }
        window.contentView = NSHostingView(rootView: settingsView)
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
