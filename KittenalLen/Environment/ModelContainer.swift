//
//  ModelContainer.swift
//  KittenalLen
//
//  Created by MeowCat on 2025/11/30.
//

import SwiftData

extension ModelContainer {
    convenience init() {
        let schema = Schema([
            Settings.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false)
        do {
            try self.init(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
