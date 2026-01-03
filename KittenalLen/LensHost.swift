//
//  LensHost.swift
//  KittenalLen
//
//  Created by MeowCat on 2025/11/30.
//

import AppKit
import SwiftUI

@MainActor
class LensHost {
    public let settings: Settings
    
    private var panels: [NSWindow] = []
    
    init(settings: Settings) {
        self.settings = settings
        resetPanels()
    }
    
    func resetPanels() {
        for panel in panels {
            panel.close()
        }
        panels = NSScreen.screens.map { screen in
            let window = NSWindow(covering: screen)
            window.contentView = NSHostingView(
                rootView: ContentView(settings: settings))
            window.orderFront(nil)
            return window
        }
    }
}

fileprivate struct ContentView: View {
    @State
    var settings: Settings
    
    @State
    var mousePosition: CGPoint = .zero
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(Color(
                    nsColor: settings.colorScheme.color
                        .withAlphaComponent(CGFloat(
                            settings.opacity) / 255)))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(HighlightingView(
            position: mousePosition - CGSize(
                width: settings.visibleWidth,
                height: settings.visibleHeight
            ) / 2
        ) {
            VisualEffectView(
                blurRadius: settings.blurRadius,
                saturationFactor: 1,
                color: UInt32(settings.peripheralDarken))
        } highlight: {
            Ellipse()
                .frame(
                    width: CGFloat(settings.visibleWidth),
                    height: CGFloat(settings.visibleHeight))
        })
        .onContinuousHover(coordinateSpace: .local) { phase in
            if case let .active(position) = phase {
                mousePosition = position
            }
        }
    }
}

fileprivate extension NSWindow {
    convenience init(covering screen: NSScreen) {
        self.init(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false)
        level = .statusBar
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        isOpaque = false
        canHide = false
        ignoresMouseEvents = true
        isMovableByWindowBackground = false
        isReleasedWhenClosed = false
    }
}
