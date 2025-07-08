//
//  upChartPlotTests.swift
//  NWer
//
//  Created by Tanaka Hiroshi on 2025/05/27.
//


import XCTest
import NWer
//@testable import UpChartPlot

final class upChartPlotTests: XCTestCase {
  let dbBase = "/Users/tanaka/Library/Application Support/ChartPlot/"
  var dbPath1: String { dbBase + "crawling.db" }
  var dbPath2: String { dbBase + "n225Hist.db" }
  var dbPath3: String { dbBase + "yatoday.db" }

  func testUpdateFromWebAPI() throws {
    let csv: CSVData = try! Networker.downloadAndParseCSV()
    print("csv.date: \(csv.date)")

    let dbBase = "/Users/tanaka/Library/Application Support/ChartPlot/"

    let dbPath1 = dbBase + "crawling.db"
    let dbPath2 = dbBase + "n225Hist.db"
//    let recent: String = try! Networker.getLatest(dbBase)!
//    print("sqlite3 latest date: \(recent ?? "no data")")

    print("TESTS")
  }
}
