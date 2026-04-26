# KittenalLen (main module)

## Purpose

Contains the core application: the `@main` entry point, the lens overlay host that creates per-screen windows, and all supporting submodules (settings, views, environment).

## Core Components

- **Application.swift**: `@main` entry point. Sets up a custom `AppDelegate` that initializes SwiftData, creates the `LensHost`, and presents the settings window on first launch or when the app enters foreground.
- **LensHost.swift**: Creates one borderless `NSWindow` per screen. Each window hosts a SwiftUI `ContentView` that renders the tinted backdrop with a cursor-following highlight cutout.
- **Environment/**: SwiftData `ModelContainer` setup, debug environment variable flags, and (commented-out) `UserDefaults` extensions.
- **Settings/**: The `Settings` SwiftData model and the `SettingsView` UI window.
- **Views/**: Custom views (`BackdropView`, `VisualEffectView`, `HighlightingView`, `EnterableSlider`, `ColorView`) and extensions (CGPoint arithmetic, Binding conversions, color conversions).
- **Bridging-Header.h**: Exposes private Core Animation SPI (`CABackdropLayer`, `CAFilter`, `CGSSetWindowTags`, `CGSFlushSurface`) to Swift.
- **Foundation/**: Convenient extensions. `String?` extension with `.isTrue` for parsing environment variable values.

## Architecture & Patterns

- **No SwiftUI `App` protocol**: Uses procedural `NSApplication.shared.run()` with a custom `NSApplicationDelegate` because it is not an usual single-window app.
- **Borderless overlay windows**: Windows use `.borderless` style mask, `.statusBar` level, ignore mouse events, and join all spaces — making them invisible overlays that don't interfere with normal interaction.
- **SwiftData with explicit `ModelContainer` extension**: A dedicated `ModelContainer` initializer sets up the schema (`Settings.self`) and loads/creates settings via `loadSettings()`.

### Key Interaction Flow

1. `Application.main()` calls `NSApplication.shared.run()` with an `AppDelegate`.
2. `applicationDidFinishLaunching` loads settings from SwiftData, creates `LensHost(settings:)`.
3. `LensHost.init` creates per-screen overlay windows via `NSWindow(covering:)`.
4. Each window's `ContentView` renders a colored backdrop + `HighlightingView` that tracks mouse position via `.onContinuousHover`.
5. On first launch (or when entering foreground with settings window closed), the settings window is shown.
