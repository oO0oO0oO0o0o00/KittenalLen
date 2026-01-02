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
    enum ColorPreset: CaseIterable {
        case orange, purple
    }
    
    var autoStart: Bool = false
    
    var isFirstLaunch: Bool = true
    
    var color: UInt32 = 0
    
    var exteriorColor: UInt32 = 0
    
    var blurRadius: CGFloat = 5
    
    var visibleWidth: Int = 400
    
    var visibleHeight: Int = 200
    
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
