import XCTest
@testable import BrighterCore

final class BoostSettingTests: XCTestCase {
    func testUnsupportedScreenCannotBoost() {
        let setting = BoostSetting(requested: 2, headroom: 1)
        XCTAssertFalse(setting.isSupported)
        XCTAssertEqual(setting.factor, 1)
    }

    func testRequestedFactorIsClampedToDisplayHeadroom() {
        let setting = BoostSetting(requested: 3, headroom: 2.4)
        XCTAssertTrue(setting.isSupported)
        XCTAssertEqual(setting.factor, 2.4)
    }

    func testRequestedFactorNeverGoesBelowNormal() {
        XCTAssertEqual(BoostSetting(requested: -4, headroom: 3).factor, 1)
    }

    func testLargeHeadroomIsLimitedToFourTimes() {
        let setting = BoostSetting(requested: 16, headroom: 16)
        XCTAssertEqual(setting.maximumFactor, 4)
        XCTAssertEqual(setting.factor, 4)
    }

    func testInvalidNumbersFallBackToNormal() {
        XCTAssertEqual(BoostSetting(requested: .nan, headroom: 3).factor, 1)
        XCTAssertEqual(BoostSetting(requested: 2, headroom: .infinity).factor, 1)
    }
}
