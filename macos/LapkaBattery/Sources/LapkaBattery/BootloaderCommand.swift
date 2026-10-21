import Foundation

struct BootloaderCommand {
    static let reportID: UInt8 = 0x05
    static let bytes: [UInt8] = [reportID, 0xA5, 0x5A]
}

struct BootloaderConfirmation {
    private var armedAt: TimeInterval?

    mutating func click(at time: TimeInterval) -> Bool {
        if let armedAt, time >= armedAt, time - armedAt <= 10 {
            self.armedAt = nil
            return true
        }
        armedAt = time
        return false
    }

    mutating func cancel() { armedAt = nil }
}
