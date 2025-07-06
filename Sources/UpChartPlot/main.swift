//
//  main.swift
//  UpChartPlot
//
//  Created by Tanaka Hiroshi on 2025/02/12.
//
import Foundation
import NWer
let dbBase = "/Users/tanaka/Library/Application Support/ChartPlot/"

let dbPath1 = dbBase + "crawling.db"
let dbPath2 = dbBase + "n225Hist.db"
let dbPath3 = dbBase + "yatoday.db"
if #available(macOS 12.0, *) {
  Networker.syncStock(dbPath1, dbPath2)
} else {
  print("This feature requires macOS 12.0 or later")
  exit(1)
}
//Networker.updateFromWebAPI(dbPath1, dbPath2)
var codeTbl: [[String]] // 2025-07-06
if #available(macOS 12.0, *) {
  codeTbl = try! await Networker.fetchCodeTbl()
  Networker.store2CodeTbl(&codeTbl, dbPath3)
} else {
  print("This feature requires macOS 12.0 or later")
  exit(1)
}

let command = "afplay /System/Library/Sounds/Ping.aiff"

let _ = executeProcessAndReturnResult(command)
// [Running Terminal Programs from Swift | by Adonis Gaitatzis | Medium](https://gaitatzis.medium.com/running-terminal-programs-from-swift-680db09a02b4)
