//  Created by Tanaka Hiroshi on 2025/02/11.
import Foundation
import SQLite
// エラーハンドリング用の型定義
enum DownloadError: Error {
  case invalidUrl
  case failedToLoad
  case invalidFormat
}

// CSVデータの構造体定義
public struct CSVData {
  let code: String
  let open: Double
  let high: Double
  let low: Double
  let close: Double
  let volume: Double
  let adj: Double

  init(_ code: String,_  open: Double,_  high: Double,
       _ low: Double,_  close: Double,_  volume: Double,_  adj: Double) {
    self.code = code
    self.open = open
    self.high = high
    self.low = low
    self.close = close
    self.volume = volume
    self.adj = adj
  }
}

let ar: [CSVData] = [CSVData("0000",260.0,261.0,255.0,256.0,313600.0,256.0),
   CSVData("397A",260.0,261.0,255.0,256.0,313600.0,256.0),
   CSVData("300A",986.0,1008.0,971.0,981.0,51300.0,981.0)]

extension Networker {
  // MARK: UpdateFromWebAPI

  @available(macOS 12.0, *) // upDateFromWebAPI
  public static func updateFromWebAPI(_ dbPath1: String, _ dbPath2: String) ->  Void {

    let ar = try! downloadAndParseCSV()
    let recent: String = try! getDate()

    for (i, e) in ar.enumerated() {
      if i % 500 == 0 {
        print("i: \(i), e: \(e.code)")
      }

      var dbPath = dbPath1
      if e.code < "1301" {
        dbPath = dbPath2
      }
//      if e.code == "1301" {
//        print("1301 found")
//        break
//      }
      let tbl: Table = Table(e.code)
//      let date = Expression<String>("date")

      do {
        // データベースに接続
        let db = try Connection(dbPath)

        // usersテーブルの存在を確認するクエリ
        let query = "SELECT name FROM sqlite_master WHERE type='table' AND name='\(e.code)';"
        let insert = tbl.insert(date <- recent, open <- e.open, high <- e.high, low <- e.low, close <- e.close, volume <- e.volume, adj <- e.adj)

        // クエリを実行
        if let _ = try? db.prepare(query).next() {
          let _ = try db.run(insert)
//          print("\(e.code): テーブルが存在します。")
        } else {
          try db.run(tbl.create { t in
            t.column(date, primaryKey: true)
            t.column(open)
            t.column(high)
            t.column(low)
            t.column(close)
            t.column(volume)
            t.column(adj)
          })
          let _ = try db.run(insert)
//          print("\(e.code): テーブルは存在しません。")
        }

      } catch {
        print("エラーが発生しました: \(error)")
      }
    }
  }

  // CSVファイルをダウンロードしてパースする関数
  //let url: String = "https://tw.lan/recent/recent.csv"
  public static func downloadAndParseCSV(from url: String = "https://stock.bad.mn/recent/recent.csv") throws -> [CSVData] {
    guard let url = URL(string: url) else {
      throw DownloadError.invalidUrl
    }

    // ファイルの内容を文字列として取得
    guard let content = try? String(contentsOf: url, encoding: .utf8) else {
      throw DownloadError.failedToLoad
    }

    // 行に分割（1行目はヘッダーなのでスキップ）
    let lines = content.components(separatedBy: "\n") //.dropFirst()
    let filtered = lines.filter{ !$0.isEmpty } // 最後の空行を削除
    var result: [CSVData] = []

    // 各行を処理
    for line in filtered {
      // カンマで区切って要素を取得
      let components = line.components(separatedBy: ",")

      // 必要な要素が揃っているかチェック
      guard components.count >= 7 else {
        throw DownloadError.invalidFormat
      }

      // 数値の変換（カンマを削除してDoubleに変換）
      guard let open = Double(components[1].replacingOccurrences(of: ",", with: "")),
            let high = Double(components[2].replacingOccurrences(of: ",", with: "")),
            let low = Double(components[3].replacingOccurrences(of: ",", with: "")),
            let close = Double(components[4].replacingOccurrences(of: ",", with: "")),
            let volume = Double(components[5].replacingOccurrences(of: ",", with: "")),
            let adj = Double(components[6].replacingOccurrences(of: ",", with: "")) else {
        throw DownloadError.invalidFormat
      }

      result.append(CSVData(components[0], open, high, low, close, volume, adj))
    }

    return result
  }
  // MARK: GetDate using Web API
  public static func getDate(from url: String = "https://stock.bad.mn/recent") throws -> String {
    guard let url = URL(string: url) else {
      throw DownloadError.invalidUrl
    }
    // ファイルの内容を文字列として取得
    guard let content = try? String(contentsOf: url, encoding: .utf8) else {
      throw DownloadError.failedToLoad
    }
    return content
  }

}
