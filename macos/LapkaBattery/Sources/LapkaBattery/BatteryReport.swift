struct BatteryReport: Equatable {
    static let reportID: UInt8 = 0x04
    let slot0: Int?
    let slot1: Int?

    init?(bytes: [UInt8]) {
        guard bytes.count == 3, bytes[0] == Self.reportID else { return nil }
        func decode(_ byte: UInt8) -> Int? { byte <= 100 ? Int(byte) : nil }
        guard bytes[1] <= 100 || bytes[1] == 0xFF,
              bytes[2] <= 100 || bytes[2] == 0xFF else { return nil }
        slot0 = decode(bytes[1])
        slot1 = decode(bytes[2])
    }

    func menuBarTitle(swapped: Bool) -> String {
        let left = swapped ? slot1 : slot0
        let right = swapped ? slot0 : slot1
        func title(_ value: Int?) -> String { value.map { "\($0)%" } ?? "—" }
        return "Л \(title(left)) · П \(title(right))"
    }
}
