//
//  String.swift
//  KittenalLen
//
//  Created by MeowCat on 2025/11/30.
//

import Foundation

extension String? {
    var isTrue: Bool {
        let trimmed = self?.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        return trimmed == "true"
            || trimmed == "yes"
            || trimmed == "y"
    }
}
