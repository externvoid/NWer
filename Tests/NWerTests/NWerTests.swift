import XCTest
@testable import NWer

final class NWerTests: XCTestCase {
  let dbBase = "/Users/tanaka/Library/Application Support/ChartPlot/"
  var dbPath1: String { dbBase + "crawling.db" }
  var dbPath2: String { dbBase + "n225Hist.db" }
  var dbPath3: String { dbBase + "yatoday.db" }

  func testQueryHist() throws {
      // XCTest Documentation
      // https://developer.apple.com/documentation/xctest

      // Defining Test Cases and Test Methods
      // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
    Task {
      var a = try! await Networker.fetchHist("0000")
      print(a[0...2])
      print(a[57...59])
      print("ar count: \(a.count)")
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
    Networker.updateFromWebAPI(dbPath1, dbPath2)
  }

  func testGetDate() throws {
    let a = try! Networker.getDate()
    print("Date: \(a)")
  }
  func testHasUpdated() throws {
    let a = Networker.hasUpdated("2025-04-04", dbPath1)
    print("Bool: \(a)")
  }
  func testSyncStock() throws {
    Networker.syncStock(dbPath1, "")
//    print("sqlite3 latest date: \(a ?? "no data")")
  }
  func testGetUpdateFiles() throws {
    let ar: [String] = try! Networker.getUpdateFiles(dbPath1) // [] or ["2025-..", "2025-..]
    print("sqlite3 latest date: \(ar.description)")
  }
  // !!!: 2025-07-08Tu
  func testQueryHist2() throws {
    Networker.initDB(dbPath3)
    Task {
      // MARK: Hist
      var a = try! await Networker.queryHist("0000", dbPath1, dbPath2, 100)
      print(a[0...2])
      print(a[97...99])
      print("ar count: \(a.count)")
      a = try! await Networker.queryHist("1822", dbPath1, dbPath2, 100)
      print(a[0...2])
      print(a[97...99])
      print("ar count: \(a.count)")
    }
    RunLoop.current.run(until: Date() + 0.5)
}
  // !!!: 2025-07-08Tu
  func testQueryCodeTbl2() throws {
    Networker.initDB(dbPath3)
    Task {
      let b = try! await Networker.queryCodeTbl(dbPath3, dbPath2)
//      print(b[0...2])
      print(b[37...39])
      print("ar count: \(b.count)")
    }
    RunLoop.current.run(until: Date() + 0.5)
  }
  // !!!: New
  func testfetchCodeTblNStore() throws {
    Task {
      // 最新レコードへのalias codeTblから必要カラムのみを取り出すWeb API
      var codeTbl = try! await Networker.fetchCodeTbl()
      //      print(b[0...2])
      print(codeTbl[37...39])
      print("codeTbl count: \(codeTbl.count)")
      Networker.store2CodeTbl(&codeTbl, dbPath3)
    }
    RunLoop.current.run(until: Date() + 1.5)
  }
}
