import XCTest
@testable import NWer

final class NWerTests: XCTestCase {
    func testExample() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
      Task {
//        let a = try! await Networker.fetchHist("1301")
        let a = try! await Networker.queryHist("1301")
//        let a = try! await Networker.queryCodeTbl()
//          let a = try! await Networker.queryCodeTbl2()
//        let a = try! await Networker.fetchCodeTbl()
        print(a[0...2])
        print(a[57...59])
      }
      RunLoop.current.run(until: Date() + 1.5)
    }
}
