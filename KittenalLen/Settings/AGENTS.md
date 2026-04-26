# Settings

## Purpose

The `Settings` SwiftData model and the settings UI window. Stores all user-configurable lens parameters and presents them in a macOS window.

## Core Components

- **Settings.swift**: `@Model` class with user-configurable properties:
  - `colorScheme`: one of `.orange`, `.purple`, `.blue`, `.teal` — the tint color of the overlay.
  - `opacity`: `UInt8` (0–200) — transparency of the overlay.
  - `peripheralDarken`: `UInt8` (0–200) — darkness level outside the highlight area.
  - `blurRadius`: `CGFloat` (0–20) — gaussian blur amount.
  - `visibleWidth` / `visibleHeight`: `Int` — dimensions of the clear area around the cursor.
  - `autoStart`: `Bool` — whether to register as a login item via `SMAppService`.
  - `isFirstLaunch`: `Bool` — tracks whether to show the settings window automatically.
  
  Also extends `ModelContainer` with `loadSettings()` for fetching/creating the singleton `Settings` instance.

- **SettingsView.swift**: SwiftUI view for the settings window. Uses a `Grid` layout with `EnterableSlider` controls for each numeric setting, color scheme toggles via `ColorView` swatches, and an auto-start toggle backed by `SMAppService.mainApp.register()`/`unregister()`. Displays inline error messages if registration fails.

## Architecture & Patterns

- **Singleton settings**: The app expects exactly one `Settings` instance in SwiftData. `loadSettings()` enforces this by fetching with `predicate: .true` and creating one if absent.
- **`Binding.oneHot` for color scheme**: The color scheme toggle group uses `Binding.oneHot` to ensure only one scheme is selected at a time — a custom mutual-exclusion binding pattern defined in `Binding+Conversions.swift`.
- **`SMAppService` for login items**: Uses the modern Service Management framework (macOS 13+) rather than deprecated `LSSharedFileList` or `launchd` plists.

## Usage

```swift
// Settings is loaded via ModelContainer:
let container = ModelContainer()
let settings = container.loadSettings()

// Present the settings UI:
let view = SettingsView(settings: settings)
let window = NSWindow()
window.contentView = NSHostingView(rootView: view)
window.makeKeyAndOrderFront(nil)
```
