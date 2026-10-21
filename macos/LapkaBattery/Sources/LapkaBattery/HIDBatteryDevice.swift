import Foundation
import IOKit.hid

final class HIDBatteryDevice {
    private let manager: IOHIDManager

    init() {
        manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        let match: [String: Int] = [
            kIOHIDDeviceUsagePageKey as String: 0xFF00,
            kIOHIDDeviceUsageKey as String: 0x01,
        ]
        IOHIDManagerSetDeviceMatching(manager, match as CFDictionary)
        IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
    }

    func read() -> BatteryReport? {
        guard let devices = IOHIDManagerCopyDevices(manager) as? Set<IOHIDDevice> else {
            return nil
        }
        for device in devices {
            guard IOHIDDeviceOpen(device, IOOptionBits(kIOHIDOptionsTypeNone)) == kIOReturnSuccess else {
                continue
            }
            defer { IOHIDDeviceClose(device, IOOptionBits(kIOHIDOptionsTypeNone)) }
            var bytes: [UInt8] = [BatteryReport.reportID, 0, 0]
            var length = bytes.count
            let result = bytes.withUnsafeMutableBufferPointer { buffer in
                IOHIDDeviceGetReport(device, kIOHIDReportTypeInput, CFIndex(BatteryReport.reportID),
                                     buffer.baseAddress!, &length)
            }
            if result == kIOReturnSuccess,
               let report = BatteryReport(bytes: Array(bytes.prefix(length))) {
                return report
            }
        }
        return nil
    }
}
