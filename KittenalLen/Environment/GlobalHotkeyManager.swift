//
//  GlobalHotkeyManager.swift
//  KittenalLen
//

import Carbon
import Cocoa

final class GlobalHotkeyManager {
    private var hotkeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?

    var onHotkeyPressed: (() -> Void)?

    func register(keyCode: Int, modifiers: Int) {
        unregister()

        let hotkeyID = EventHotKeyID(signature: 0x4B454E4C, id: 1) // "KENL"
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: OSType(kEventHotKeyPressed))

        let selfPtr = Unmanaged.passUnretained(self).toOpaque()

        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, _, userData) -> OSStatus in
                guard let userData = userData else { return noErr }
                let manager = Unmanaged<GlobalHotkeyManager>
                    .fromOpaque(userData)
                    .takeUnretainedValue()
                DispatchQueue.main.async {
                    manager.onHotkeyPressed?()
                }
                return noErr
            },
            1,
            &eventType,
            selfPtr,
            &eventHandlerRef)

        guard status == noErr else {
            debugPrint("GlobalHotkeyManager: InstallEventHandler failed \(status)")
            return
        }

        let regStatus = RegisterEventHotKey(
            UInt32(keyCode),
            UInt32(modifiers),
            hotkeyID,
            GetApplicationEventTarget(),
            0,
            &hotkeyRef)

        if regStatus != noErr {
            debugPrint("GlobalHotkeyManager: RegisterEventHotKey failed \(regStatus)")
            unregister()
        }
    }

    func unregister() {
        if let ref = hotkeyRef {
            UnregisterEventHotKey(ref)
            hotkeyRef = nil
        }
        if let handlerRef = eventHandlerRef {
            RemoveEventHandler(handlerRef)
            eventHandlerRef = nil
        }
    }

    deinit {
        unregister()
    }
}
