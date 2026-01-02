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
                    Text("Blur Radius")
                    EnterableSlider(
                        value: .convert($settings.blurRadius),
                        range: 0...20)
                }
                rgbSelecter(color: $settings.color)
                rgbSelecter(color: $settings.exteriorColor, name: "Exterior")
            }
            HStack {
                Text("BG Color: \(String(format: "%08X", settings.color))")
                    .font(.default.monospaced())
                ColorView(color: .init(rgba: settings.color))
            }
            HStack {
                Text("Presets")
                ForEach(Settings.ColorPreset.allCases, id: \.self) { preset in
                    Button {
                        settings.color = preset.color.int
                    } label: {
                        ColorView(color: preset.color)
                    }
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
    
    func rgbSelecter(color: Binding<UInt32>, name: String = "") -> some View {
        let prefix = name.isEmpty ? name : "\(name) "
        return ForEach([
            (name: "\(prefix)Red", offset: 24),
            (name: "\(prefix)Green", offset: 16),
            (name: "\(prefix)Blue", offset: 8),
            (name: "\(prefix)Alpha", offset: 0),
        ] as [(name: String, offset: UInt8)], id: \.name) { component in
            GridRow {
                Text(component.name)
                EnterableSlider(
                    value: .convert(Binding<UInt>.intComponent(
                        from: color,
                        offset: component.offset,
                        mask: 0xff
                    )), range: 0...(component.offset == 0 ? 220 : 255))
            }
        }
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

fileprivate extension Settings.ColorPreset {
    var color: NSColor {
        return switch self {
        case .orange:
            NSColor.orange.withAlphaComponent(0.8)
        case .purple:
            (NSColor.blue.blended(
                withFraction: 0.5, of: .orange
            ) ?? .blue).withAlphaComponent(0.8)
        }
    }
}

fileprivate enum AutoStartErrorKind: String {
    case register, unregister
}
