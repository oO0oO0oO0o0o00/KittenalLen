//
//  GlobalHotkeyManager.swift
//  KittenalLen
//

import Carbon
import Cocoa

final class GlobalHotkeyManager {
    private var hotkeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    private let hotkeyID: EventHotKeyID

    var onHotkeyPressed: (() -> Void)?

    init(id: UInt32 = 1) {
        self.hotkeyID = EventHotKeyID(signature: 0x4B454E4C, id: id)
    }

    func register(keyCode: Int, modifiers: Int) {
        unregister()

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: OSType(kEventHotKeyPressed))

        let selfPtr = Unmanaged.passUnretained(self).toOpaque()

        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, event, userData) -> OSStatus in
                guard let userData = userData else { return noErr }
                let manager = Unmanaged<GlobalHotkeyManager>
                    .fromOpaque(userData)
                    .takeUnretainedValue()
                var eventHotKeyID = EventHotKeyID()
                let err = GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &eventHotKeyID)
                if err != noErr || eventHotKeyID.id != manager.hotkeyID.id {
                    return OSStatus(eventNotHandledErr)
                }
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
