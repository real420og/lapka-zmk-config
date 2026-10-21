import XCTest
@testable import LapkaBattery

final class BatteryReportTests: XCTestCase {
    func testParsesTwoValidPercentagesIncludingZero() {
        let report = BatteryReport(bytes: [0x04, 0, 87])
        XCTAssertEqual(report?.slot0, 0)
        XCTAssertEqual(report?.slot1, 87)
        XCTAssertEqual(report?.menuBarTitle(swapped: false), "Л 0% · П 87%")
    }

    func testUnknownAndSwappedLabels() {
        let report = BatteryReport(bytes: [0x04, 0xFF, 42])
        XCTAssertEqual(report?.menuBarTitle(swapped: false), "Л — · П 42%")
        XCTAssertEqual(report?.menuBarTitle(swapped: true), "Л 42% · П —")
    }

    func testRejectsWrongIdLengthAndOutOfRangePercentages() {
        XCTAssertNil(BatteryReport(bytes: [0x03, 40, 50]))
        XCTAssertNil(BatteryReport(bytes: [0x04, 40]))
        XCTAssertNil(BatteryReport(bytes: [0x04, 101, 50]))
    }
}
