# Views

## Purpose

Custom SwiftUI views, `NSView`/`NSVisualEffectView` subclasses, and geometry/color/binding extensions that compose the lens overlay. The key visual effect is: a full-screen blurred & tinted backdrop with a clear "porthole" around the mouse cursor.

## Core Components

- **BackdropView.swift**: `NSVisualEffectView` subclass that uses `CABackdropLayer` (private SPI) to apply gaussian blur and color saturation. Supports `BlendGroup` for compositing multiple backdrops together. This is the low-level blur engine — it disables the standard `NSVisualEffectView` rendering and inserts its own `CABackdropLayer` with `CAFilter` effects.
- **VisualEffectView.swift**: SwiftUI `NSViewRepresentable` wrapper around `BackdropView`. Configures `blurRadius`, `saturationFactor`, and background `color` (as `UInt32` RGBA).
- **HighlightingView.swift**: Creates a "cutout" effect using `matchedGeometryEffect` — one copy of the highlight shape acts as a geometry source; the other is rendered white, blurred, and blended with `.destinationOut` to punch a hole through the backdrop. The hole follows the mouse position.
- **EnterableSlider.swift**: A combined `Slider` + `TextField` for numeric settings input, with configurable range and optional step. Uses `NumberFormatter` for display.
- **ColorView.swift**: A simple colored rectangle swatch used in the settings UI for color scheme selection.
- **CGPoint+Arith.swift**: Arithmetic operator extensions (`+`, `-`, `*`, `/`) on `CGPoint` and `CGSize` for mouse-position math.
- **Binding+Conversions.swift**: `Binding` conversion helpers — `convert` for numeric type bridging and `oneHot` for mutually-exclusive toggle groups.
- **Color+Int.swift**: `NSColor` extensions for converting to/from `UInt32` RGBA packed representation.
- **ColorScheme+Color.swift**: Maps `Settings.ColorScheme` enum cases to `NSColor` values (orange, purple, blue, teal).
- **View+Map.swift**: Conditional view modifier helpers (`map` and `mapOptional`) for inline optional branching in SwiftUI view builders.

## Architecture & Patterns

- **SPI-driven blur**: `BackdropView` bypasses `NSVisualEffectView`'s built-in rendering and directly manages a `CABackdropLayer` with gaussian blur and color-saturate filters. It observes system color changes, blend group deallocation, and layer surface flattening events.
- **Cutout via blend mode**: `HighlightingView` uses `blendMode(.destinationOut)` on a blurred white shape to subtract the highlight region from the backdrop — creating a clear area around the cursor.
- **CGWindowServer integration**: `BackdropView` calls `CGSSetWindowTags` (private SPI) and handles `CGSFlushSurface` for WindowServer-aware rendering after window transforms (Mission Control, etc.).

## Usage

### Using BackdropView directly
```swift
let backdrop = BackdropView(frame: .zero)
backdrop.blurRadius = 10
backdrop.saturationFactor = 1.5
backdrop.backgroundColor = NSColor.black.withAlphaComponent(0.3)
backdrop.blendingMode = .behindWindow
```

### Using HighlightingView with a backdrop
```swift
HighlightingView(position: mousePosition) {
    VisualEffectView(blurRadius: 5, saturationFactor: 1, color: 0x00000080)
} highlight: {
    Ellipse()
        .frame(width: 1000, height: 400)
}
```
