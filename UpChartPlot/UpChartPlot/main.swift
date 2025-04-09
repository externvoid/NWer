//
//  main.swift
//  UpChartPlot
//
//  Created by Tanaka Hiroshi on 2025/02/12.
//
import NWer
let dbBase = "/Users/tanaka/Library/Application Support/ChartPlot/"

let dbPath1 = dbBase + "crawling.db"
let dbPath2 = dbBase + "n225Hist.db"
Networker.updateFromWebAPI(dbPath1, dbPath2)

import Foundation
func executeProcessAndReturnResult(_ command: String) -> String {
  let process = Process()
  let pipe = Pipe()
  let environment = [
    "TERM": "xterm",
    "HOME": "/Users/tanaka/",
    "PATH": "/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
  ]
  process.standardOutput = pipe
  process.standardError = pipe
  process.environment = environment
  process.launchPath = "/bin/zsh"
  process.arguments = ["-c", command]
  if #available(macOS 13.0, *) {
    try! process.run()
  } else {
    process.launch()
  }
  let data = pipe.fileHandleForReading.readDataToEndOfFile()
  let output = String(data: data, encoding: .utf8) ?? ""
  return output
}
let command = "afplay /System/Library/Sounds/Ping.aiff"

let _ = executeProcessAndReturnResult(command)
// [Running Terminal Programs from Swift | by Adonis Gaitatzis | Medium](https://gaitatzis.medium.com/running-terminal-programs-from-swift-680db09a02b4)
