//  Created by Tanaka Hiroshi on 2025/02/11.
//  modified by Tanaka Hiroshi on 2025/04/05.
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
  public let date: String
  var ar: [OHLCVA]
  init(_ date: String, _ ar: [OHLCVA]) {
    self.date = date
    self.ar = ar
  }
  struct OHLCVA {
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
}

let ar: [CSVData.OHLCVA] = [CSVData.OHLCVA("0000",260.0,261.0,255.0,256.0,313600.0,256.0),
                            CSVData.OHLCVA("397A",260.0,261.0,255.0,256.0,313600.0,256.0),
                            CSVData.OHLCVA("300A",986.0,1008.0,971.0,981.0,51300.0,981.0)]

extension Networker {
  // MARK: UpdateFromWebAPI

  @available(macOS 12.0, *) // upDateFromWebAPI
  public static func updateFromWebAPI(_ dbPath1: String, _ dbPath2: String) ->  Void {

    let csv: CSVData = try! downloadAndParseCSV()
    //    let recent: String = try! getDate)
    if hasUpdated(csv.date, dbPath1) {print("already updated"); return}

    for (i, e) in csv.ar.enumerated() {
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
      if e.adj < 0.0 {
        adjUpdate(e, csv.date, dbPath)
      } else {
        planeUpdate(e, csv.date, dbPath)
      }
    }
  }
  static func adjUpdate(_ e: CSVData.OHLCVA, _ dateStr: String, _ dbPath: String) {
    let tbl: Table = Table(e.code)
    let rate: Double = abs(e.adj)
    print("code:\(e.code), adj rate: \(rate)")
    do {
      // データベースに接続
      let db = try Connection(dbPath)
      try! db.execute("PRAGMA journal_mode=wal;")
      let update = tbl.update(Networker.adj <- Networker.close / rate)
      // クエリを実行
      let _ = try db.run(update)

    } catch {
      print("エラーが発生しました@adjUpdate: \(error)")
    }
    planeUpdate2(e, dateStr, dbPath)
  }
  static func planeUpdate2(_ e: CSVData.OHLCVA, _ dateStr: String, _ dbPath: String) {
    let tbl: Table = Table(e.code)
    do {
      // データベースに接続
      let db = try Connection(dbPath)
      try! db.execute("PRAGMA journal_mode=wal;")

      // usersテーブルの存在を確認するクエリ
      let query = "SELECT name FROM sqlite_master WHERE type='table' AND name='\(e.code)';"
      let insert = tbl.insert(Networker.date <- dateStr,
                              Networker.open <- e.open, Networker.high <- e.high, Networker.low <- e.low,
                              Networker.close <- e.close, Networker.volume <- e.volume,
                              Networker.adj <- e.close) // note: e.adj is rate
      // e.adjの値に応じて処理を分岐
      // クエリを実行
      if let _ = try? db.prepare(query).next() {
        let _ = try db.run(insert)
        //          print("\(e.code): テーブルが存在します。")
      } else {
        try db.run(tbl.create { t in
          t.column(Networker.date, primaryKey: true)
          t.column(Networker.open)
          t.column(Networker.high)
          t.column(Networker.low)
          t.column(Networker.close)
          t.column(Networker.volume)
          t.column(Networker.adj)
        })
        let _ = try db.run(insert)
        //          print("\(e.code): テーブルは存在しません。")
      }

    } catch {
      print("エラーが発生しました@planeUpdate: \(error)")
    }
  }
  static func hasUpdated(_ dateStr: String, _ dbPath: String) -> Bool {
    do {
      // データベースに接続
      let db = try Connection(dbPath)
      let query = "SELECT date FROM '1301' order by date desc limit 1;"
      let a = try? db.prepare(query).next()
      if let a = a {
        print("db  date: \(a[0]!)")
        return dateStr == a[0]! as! String
      } else {
        print("no data")
      }
    } catch {
      print("エラーが発生しました@lastUpdate: \(error)")
    }
    return false
  }
  static func planeUpdate(_ e: CSVData.OHLCVA, _ dateStr: String, _ dbPath: String) {
    let tbl: Table = Table(e.code)
    do {
      // データベースに接続
      let db = try Connection(dbPath)
      try! db.execute("PRAGMA journal_mode=wal;")
      // usersテーブルの存在を確認するクエリ
      let query = "SELECT name FROM sqlite_master WHERE type='table' AND name='\(e.code)';"
      let insert = tbl.insert(Networker.date <- dateStr, Networker.open <- e.open, Networker.high <- e.high, Networker.low <- e.low, Networker.close <- e.close, Networker.volume <- e.volume, Networker.adj <- e.adj)
      // e.adjの値に応じて処理を分岐
      // クエリを実行
      if let _ = try? db.prepare(query).next() {
        let _ = try db.run(insert)
        //          print("\(e.code): テーブルが存在します。")
      } else {
        try db.run(tbl.create { t in
          t.column(Networker.date, primaryKey: true)
          t.column(Networker.open)
          t.column(Networker.high)
          t.column(Networker.low)
          t.column(Networker.close)
          t.column(Networker.volume)
          t.column(Networker.adj)
        })
        let _ = try db.run(insert)
        //          print("\(e.code): テーブルは存在しません。")
      }

    } catch {
      print("エラーが発生しました@planeUpdate: \(error)")
    }
  }

  // CSVファイルをダウンロードしてパースする関数
  //let url: String = "https://tw.lan/recent/recent.csv"

  // MARK: DownloadAndParseCSV

  public static func downloadAndParseCSV(from url: String = "https://stock.bad.mn/recent/recent.csv") throws -> CSVData {
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
    let dateStr: String! = filtered.first; let ohlcs = filtered.dropFirst()
    var result: CSVData = CSVData(dateStr, [])
    print("csv date: \(result.date)")

    // 各行を処理
    for line in ohlcs {
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

      result.ar.append(CSVData.OHLCVA(components[0], open, high, low, close, volume, adj))
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
