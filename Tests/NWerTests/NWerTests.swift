import XCTest
@testable import NWer

final class NWerTests: XCTestCase {
    func testExample() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
      let a = Networker.queryHist()
      print(a[0...2])
    }
}
