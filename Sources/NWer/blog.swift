//
//  blog.swift
//  NWer
//
//  Created by Tanaka Hiroshi on 2025/04/17.
import Foundation
// シリアルキューを用意（グローバルに）
let serialQueue = DispatchQueue(label: "com.example.doSomethingQueue")


@available(macOS 10.15, *)
extension Task where Success == Never, Failure == Never {
  static func sleep(seconds duration: TimeInterval) async throws {
    let delay = UInt64(duration * 1000_000_000)
    try await Task.sleep(nanoseconds: delay)
  }
}
