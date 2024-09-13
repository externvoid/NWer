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
        a = try! await Networker.queryHist("0000", dbPath1, dbPath2)
        print(a[0...2])
        print(a[57...59])
        print("ar count: \(a.count)")
        a = try! await Networker.queryHist("1301", dbPath1, dbPath2)
        print(a[0...2])
        print(a[57...59])
        print("ar count: \(a.count)")
        let dbPath3 = dbBase + "yatoday.db"
        let b = try! await Networker.queryCodeTbl(dbPath3, dbPath2)
        print(b[0...2])
        print(b[57...59])
        print("ar count: \(b.count)")
//          let a = try! await Networker.queryCodeTbl2()
//        let a = try! await Networker.fetchCodeTbl()
      }
      RunLoop.current.run(until: Date() + 3.5)
    }
}
