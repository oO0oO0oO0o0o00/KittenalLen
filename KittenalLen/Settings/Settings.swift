//
//  Settings.swift
//  KittenalLen
//
//  Created by MeowCat on 2025/11/30.
//

import Foundation
import SwiftData

@Model
final class Settings {
    enum ColorScheme: Codable, CaseIterable {
        case orange, purple, blue, teal
    }
    
    var autoStart: Bool = false
    
    var isFirstLaunch: Bool = true
    
    var colorScheme: ColorScheme = ColorScheme.orange
    
    var opacity: UInt8 = 100
    
    var peripheralDarken: UInt8 = 50
    
    var blurRadius: CGFloat = 5
    
    var visibleWidth: Int = 1000
    
    var visibleHeight: Int = 400
    
    init() { }
}

extension ModelContainer {
    func loadSettings() -> Settings {
        if Application.debugRemoveSettings {
            do {
                try mainContext.delete(model: Settings.self)
                debugPrint("Remove settings.")
            } catch {
                debugPrint("Cannot remove settings: \(error)")
            }
        }
        do {
            if let settings = try mainContext.fetch(
                FetchDescriptor<Settings>(predicate: .true)).first {
                return settings
            } else {
                let settings = Settings()
                mainContext.insert(settings)
                return settings
            }
        } catch {
            fatalError("Could not fetch Settings: \(error)")
        }
    }
}
