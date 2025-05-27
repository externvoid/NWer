//
//  helper.swift
//  NWer
//
//  Created by Tanaka Hiroshi on 2025/05/27.
//

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
