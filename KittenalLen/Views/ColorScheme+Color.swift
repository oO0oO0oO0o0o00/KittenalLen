//
//  ColorScheme+Color.swift
//  KittenalLen
//
//  Created by MeowCat on 2026/1/3.
//

import AppKit

extension Settings.ColorScheme {
    var color: NSColor {
        return switch self {
        case .orange:
            NSColor.orange
        case .purple:
            (NSColor.blue.blended(
                withFraction: 0.5, of: .orange
            ) ?? .blue)
        case .blue:
            NSColor.blue
        case .teal:
            (NSColor.blue.blended(
                withFraction: 0.5, of: .green
            ) ?? .blue)
        }
    }
}
