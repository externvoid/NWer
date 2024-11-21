import XCTest
@testable import NWer

final class NWerTests: XCTestCase {
    func testExample() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
      Task {
        var a = try! await Networker.fetchHist("0000")
        print(a[0...2])
        print(a[57...59])
        print("ar count: \(a.count)")
        let dbBase = "/Volumes/twsmb/newya/asset/"
//        let dbBase = "/Volumes/homes/super/NASData/StockDB/"
        let dbPath1 = dbBase + "crawling.db"
        let dbPath2 = dbBase + "n225Hist.db"
        let dbPath3 = dbBase + "yatoday.db"
        // MARK: Hist
        a = try! await Networker.queryHist("0000", dbPath1, dbPath2, 100)
        print(a[0...2])
        print(a[57...59])
        print("ar count: \(a.count)")
        a = try! await Networker.queryHist("1301", dbPath1, dbPath2, 100)
        print(a[0...2])
        print(a[57...59])
        print("ar count: \(a.count)")
        // MARK: CodeTbl
        let b = try! await Networker.queryCodeTbl(dbPath3, dbPath2)
        print(b[0...2])
        print(b[37...39])
        print("ar count: \(b.count)")
      }
      RunLoop.current.run(until: Date() + 7.5)
    }
}
