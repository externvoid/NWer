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
      let dbBase = "/Users/tanaka/Library/Application Support/ChartPlot/"

//        let dbBase = "/Volumes/twnfs/newya/asset/"
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
  func testDownloadCSV() throws {
    let a = try! Networker.downloadAndParseCSV()
    print(a.ar[0...2])
    print(a.ar[57...59])
    print("ar count: \(a.ar.count)")
  }

  func testUpdateFromWebAPI() throws {
    let dbBase = "/Users/tanaka/Library/Application Support/ChartPlot/"

    let dbPath1 = dbBase + "crawling.db"
    //    let dbPath1 = dbBase + "stock_light.db"
    let dbPath2 = dbBase + "n225Hist.db"
    let _ = dbBase + "yatoday.db"
    Networker.updateFromWebAPI(dbPath1, dbPath2)
  }

  func testGetDate() throws {
    let a = try! Networker.getDate()
    print("Date: \(a)")
  }
  func testHasUpdated() throws {
    let dbBase = "/Users/tanaka/Library/Application Support/ChartPlot/"

    let dbPath1 = dbBase + "crawling.db"
    let a = Networker.hasUpdated("2025-04-04", dbPath1)
    print("Bool: \(a)")
  }
}
