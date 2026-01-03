//
//  SettingsView.swift
//  Neko
//
//  Created by MeowCat on 2025/1/5.
//

import Foundation
import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @State
    private var settings: Settings
    
    @State
    private var autoStartError: AutoStartErrorKind?
    
    @Environment(\.dismiss)
    private var dismiss
    
    init(settings: Settings) {
        self.settings = settings
    }
    
    @MainActor
    var body: some View {
        VStack(alignment: .leading) {
            Grid {
                GridRow {
                    Text("Visible Width")
                    EnterableSlider(
                        value: .convert($settings.visibleWidth),
                        range: 200...1500)
                }
                GridRow {
                    Text("Visible Height")
                    EnterableSlider(
                        value: .convert($settings.visibleHeight),
                        range: 100...500)
                }
                GridRow {
                    Text("Blur Level")
                    EnterableSlider(
                        value: .convert($settings.blurRadius),
                        range: 0...20)
                }
                GridRow {
                    Text("Color Scheme")
                    HStack {
                        ForEach(Settings.ColorScheme.allCases, id: \.self) { scheme in
                            Toggle(isOn: .oneHot($settings.colorScheme, current: scheme))  {
                                ColorView(color: scheme.color.withAlphaComponent(0.8))
                            }.toggleStyle(.button)
                        }
                    }
                }
                GridRow {
                    Text("Opacity")
                    EnterableSlider(
                        value: .convert($settings.opacity),
                        range: 0...200)
                }
                GridRow {
                    Text("Peripheral Darken")
                    EnterableSlider(
                        value: .convert($settings.peripheralDarken),
                        range: 0...200)
                }
            }
            Spacer()
            Toggle(isOn: $settings.autoStart) {
                Text("Start on login")
            }.onChange(of: settings.autoStart) {
                set(autoStart: settings.autoStart)
            }
            if let error = autoStartError {
                switch error {
                case .register:
                    Text("""
        Cannot register to start on login.
        Go to System Settings → General → Login Items to add.
        """).foregroundStyle(.red)
                case .unregister:
                    Text("""
        Cannot unregister to start on login.
        """).foregroundStyle(.yellow)
                }
            }
            Spacer(minLength: 24)
            HStack {
                Button("OK") {
                    dismiss()
                }.keyboardShortcut(.defaultAction)
            }
        }.padding(20).frame(minWidth: 400)
    }
    
    func set(autoStart: Bool) {
        if autoStart {
            do {
                try SMAppService.mainApp.register()
            } catch let error as NSError {
                if error.code != kSMErrorAlreadyRegistered {
                    autoStartError = .register
                    debugPrint("Cannot register autostart: \(error)")
                }
            }
        } else {
            do {
                try SMAppService.mainApp.unregister()
            } catch let error as NSError {
                if error.code != kSMErrorJobNotFound {
                    autoStartError = .unregister
                    debugPrint("Cannot unregister autostart: \(error)")
                }
            }
        }
    }
}

fileprivate enum AutoStartErrorKind: String {
    case register, unregister
}
