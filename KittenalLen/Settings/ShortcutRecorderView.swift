//
//  ShortcutRecorderView.swift
//  KittenalLen
//

import SwiftUI

struct ShortcutRecorderView: View {
    let label: String

    @Binding var keyCode: Int

    @Binding var modifiers: Int

    var otherKeyCode: Int = -1

    var otherModifiers: Int = 0

    var onChanged: (() -> Void)?

    var onRecordingStateChanged: ((Bool) -> Void)?

    @State private var isRecording = false

    @State private var eventMonitor: Any?

    @State private var errorMessage: String?

    var body: some View {
        GridRow {
            LabelText(text: label)
            Button {
                toggleRecording()
            } label: {
                Text(isRecording
                     ? "Press keys…"
                     : shortcutDisplayString(
                        keyCode: keyCode, carbonModifiers: modifiers))
                    .frame(width: 80)
                    .foregroundStyle(errorMessage != nil ? .red : .primary)
            }
        }
    }

    func toggleRecording() {
        if isRecording { stopRecording() } else { startRecording() }
    }

    func startRecording() {
        isRecording = true
        errorMessage = nil
        onRecordingStateChanged?(true)
        eventMonitor = NSEvent.addLocalMonitorForEvents(
            matching: .keyDown
        ) { event in
            handleKeyEvent(event)
            return nil
        }
    }

    func stopRecording() {
        isRecording = false
        errorMessage = nil
        onRecordingStateChanged?(false)
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }

    func handleKeyEvent(_ event: NSEvent) {
        if event.keyCode == 53 { // Escape cancels
            stopRecording()
            return
        }

        let mods = carbonModifiers(
            from: event.modifierFlags.intersection(.deviceIndependentFlagsMask))
        let code = Int(event.keyCode)

        guard !isModifierKey(code) else {
            errorMessage = "Modifier-only"
            return
        }

        if code == otherKeyCode && mods == otherModifiers {
            errorMessage = "Duplicate"
            return
        }

        guard mods != 0 || isFunctionKey(code) else {
            errorMessage = "Add modifier"
            return
        }

        errorMessage = nil
        keyCode = code
        modifiers = mods
        onChanged?()
        stopRecording()
    }
}

struct LabelText: View {
    let text: String
    var wrap: Bool = false

    var body: some View {
        Text(text)
            .frame(width: 130, alignment: .leading)
            .lineLimit(wrap ? 2 : 1)
            .fixedSize(horizontal: false, vertical: wrap)
    }
}

// MARK: - Helpers

func isModifierKey(_ keyCode: Int) -> Bool {
    [54, 55, 56, 57, 58, 59, 60, 61, 62, 63].contains(keyCode)
}

func isFunctionKey(_ keyCode: Int) -> Bool {
    [122, 120, 99, 118, 96, 97, 98, 100, 101, 109, 103, 111].contains(keyCode)
}

func carbonModifiers(from nsFlags: NSEvent.ModifierFlags) -> Int {
    var result = 0
    if nsFlags.contains(.command) { result |= 0x0100 }  // cmdKey
    if nsFlags.contains(.option)  { result |= 0x0800 }  // optionKey
    if nsFlags.contains(.control) { result |= 0x1000 }  // controlKey
    if nsFlags.contains(.shift)   { result |= 0x0200 }  // shiftKey
    return result
}

func shortcutDisplayString(keyCode: Int, carbonModifiers: Int) -> String {
    var result = ""
    if carbonModifiers & 0x1000 != 0 { result += "⌃" }
    if carbonModifiers & 0x0800 != 0 { result += "⌥" }
    if carbonModifiers & 0x0200 != 0 { result += "⇧" }
    if carbonModifiers & 0x0100 != 0 { result += "⌘" }
    result += keyDisplayName(keyCode: keyCode)
    return result
}

func keyDisplayName(keyCode: Int) -> String {
    let letters: [Int: String] = [
        0: "A", 11: "B", 8: "C", 2: "D", 14: "E", 3: "F", 5: "G", 4: "H",
        34: "I", 38: "J", 40: "K", 37: "L", 46: "M", 45: "N", 31: "O",
        35: "P", 12: "Q", 15: "R", 1: "S", 17: "T", 32: "U", 9: "V",
        13: "W", 7: "X", 16: "Y", 6: "Z",
    ]
    if let letter = letters[keyCode] { return letter }
    let special: [Int: String] = [
        29: "0", 18: "1", 19: "2", 20: "3", 21: "4",
        23: "5", 22: "6", 26: "7", 28: "8", 25: "9",
        36: "↩", 48: "⇥", 49: "Space", 51: "⌫", 53: "⎋",
        117: "⌦", 126: "↑", 125: "↓", 123: "←", 124: "→",
        122: "F1", 120: "F2", 99: "F3", 118: "F4",
        96: "F5", 97: "F6", 98: "F7", 100: "F8",
        101: "F9", 109: "F10", 103: "F11", 111: "F12",
        82: "Num0", 83: "Num1", 84: "Num2", 85: "Num3",
        86: "Num4", 87: "Num5", 88: "Num6", 89: "Num7",
        90: "Num8", 91: "Num9",
        33: "[", 30: "]", 42: "\\", 41: ";", 39: "'",
        43: ",", 47: ".", 44: "/", 50: "`", 24: "=", 27: "-",
    ]
    return special[keyCode] ?? "Key\(keyCode)"
}
