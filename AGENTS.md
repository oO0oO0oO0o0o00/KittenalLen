# KittenalLen

## Purpose

KittenalLen is a macOS screen filter app that reduces visual contrast for eye comfort. It overlays every screen with a semi-transparent, blurred backdrop that can be tinted and dimmed, while leaving a clear "window" region around the mouse cursor. This provides visual relief when staring at high-contrast content (e.g., bright text on dark backgrounds).

It is a native SwiftUI + AppKit menubar-style app using borderless overlay windows, `CABackdropLayer`-based blur, and SwiftData for settings persistence.

## Core Components

- **KittenalLen/**: The main application module — entry point, lens overlay host, settings, views, and environment utilities.
- **Config.xcconfig**: Build configuration, imports `Signing.xcconfig` for the development team.

## Architecture & Patterns

- **@main entry point** via `Application` struct with a custom `AppDelegate` (not the SwiftUI `App` protocol).
- **Per-screen overlay windows**: `LensHost` creates one borderless `NSWindow` per `NSScreen`, each hosting a SwiftUI `ContentView`.
- **Cursor-following highlight**: `HighlightingView` uses `matchedGeometryEffect` + `blendMode(.destinationOut)` to punch a clear hole through the blur layer around the mouse.
- **SwiftData persistence**: `Settings` is a `@Model` managed by a custom `ModelContainer` setup.
- **SPI usage**: `BackdropView` wraps `CABackdropLayer` (private Core Animation API) for gaussian blur and color saturation effects.
