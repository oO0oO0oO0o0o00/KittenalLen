//
//  Vars.swift
//  KittenalLen
//
//  Created by MeowCat on 2025/11/30.
//

import Foundation

extension Application {
    static let debugSettingsUI: Bool = {
        let v = getenv("KITTENAL_LEN_DEBUG_SETTINGS_UI")
        return v.map { String(cString: $0) }.isTrue
    }()
    
    static let debugRemoveSettings: Bool = {
        let v = getenv("KITTENAL_LEN_DEBUG_REMOVE_SETTINGS")
        return v.map { String(cString: $0) }.isTrue
    }()
}
