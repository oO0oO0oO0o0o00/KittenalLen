# Environment

## Purpose

App-level infrastructure: SwiftData persistence setup, debug configuration via environment variables, and (currently unused) `UserDefaults` helpers.

## Core Components

- **ModelContainer.swift**: Extends SwiftData's `ModelContainer` with a convenience initializer that registers `Settings.self` as the schema and configures disk-based storage. Also extends `ModelContainer` with `loadSettings()` — fetches the first (and only) `Settings` object, or creates and inserts one if none exists. Handles the debug environment flag to optionally delete existing settings on launch.
- **Vars.swift**: Static computed properties on `Application` that read debug environment variables:
  - `debugSettingsUI` (`KITTENAL_LEN_DEBUG_SETTINGS_UI`) — forces settings UI to show on every launch.
  - `debugRemoveSettings` (`KITTENAL_LEN_DEBUG_REMOVE_SETTINGS`) — wipes persisted settings on launch.
- **UserDefaults.swift**: Fully commented-out — previously held `isFirstLaunch` and `autoStart` properties via `UserDefaults` before they were migrated to SwiftData's `Settings` model.

## Usage

### Environment variable configuration
```bash
# Always show settings window on launch:
KITTENAL_LEN_DEBUG_SETTINGS_UI=true /Applications/KittenalLen.app/Contents/MacOS/KittenalLen

# Wipe settings on launch:
KITTENAL_LEN_DEBUG_REMOVE_SETTINGS=true /Applications/KittenalLen.app/Contents/MacOS/KittenalLen
```

### Loading settings programmatically
```swift
let container = ModelContainer()
let settings = container.loadSettings()
```
