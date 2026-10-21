import XCTest
@testable import LapkaBattery

final class BootloaderCommandTests: XCTestCase {
    func testCommandHasFeatureReportIDAndGuardBytes() {
        XCTAssertEqual(BootloaderCommand.bytes, [0x05, 0xA5, 0x5A])
    }

    func testConfirmationRequiresSecondClickWithinTenSeconds() {
        var confirmation = BootloaderConfirmation()
        XCTAssertFalse(confirmation.click(at: 100))
        XCTAssertTrue(confirmation.click(at: 105))
        XCTAssertFalse(confirmation.click(at: 106))
        XCTAssertFalse(confirmation.click(at: 120))
        XCTAssertFalse(confirmation.click(at: 131))
    }

    func testConfirmationCanBeCancelled() {
        var confirmation = BootloaderConfirmation()
        XCTAssertFalse(confirmation.click(at: 100))
        confirmation.cancel()
        XCTAssertFalse(confirmation.click(at: 105))
    }
}
