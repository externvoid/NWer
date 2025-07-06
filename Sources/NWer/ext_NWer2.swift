//  Created by Tanaka Hiroshi on 2025/05/28.
import Foundation
import SQLite
extension Networker {
  // MARK: syncStock

  @available(macOS 12.0, *) //
  // modified from updateFromWebAPI
  public static func syncStock(_ dbPath1: String, _ dbPath2: String) ->  Void {
    let base = "https://stock.bad.mn/recent/"
    let ar: [String] = try! getUpdateFiles(dbPath1)
    if ar.isEmpty { print("no update file"); return }
    ar.forEach { e in
      print("update file: \(e)")
      let csv: CSVData = try! downloadAndParseCSV(from: base + e)
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
      } // end of for
    }
  }
  static func getLatest(_ dbPath: String) -> String? {
    do {
      // ローカル・データベースに接続
      let db = try Connection(dbPath)
      let query = "SELECT date FROM '1301' order by date desc limit 1;"
      let a = try? db.prepare(query).next()
      if let a = a?[0] {
        print("db  date: \(a)")
        return a as? String
      } else {
        print("no data")
        return nil
      }
    } catch {
      print("エラーが発生しました@lastUpdate: \(error)")
    }
    return nil
  }
  @available(macOS 12, *)
  static func getUpdateFiles(_ dbPath: String, from base: String = "https://stock.bad.mn/recent") throws -> [String] {
    //    let d: String = "2025-05-28" // !!!: for debug
    let d: String = getLatest(dbPath)!
    // let d: String = Date.now.description.components(separatedBy:" ").first! UTC
    let q: String = "?d=\(d)"
    let url: URL = .init(string: base + q)!
    guard let content = try? String(contentsOf: url, encoding: .utf8) else {
      throw DownloadError.failedToLoad
    }
    let ret = content.components(separatedBy: "\n")
    print("content: \(ret))")

    return ret.filter { $0 != "" }
  }
  //
  // codeTbl: code, company, exchange, marketcap, feature, category
  @available(macOS 12, *)
  public static func store2CodeTbl(_ codeTbl: inout [[String]], _ dbPath: String) {
    let tbl = "codeTbl", prevTbl = "prevCodeTbl"
    do {
      let db = try Connection(dbPath)//, readonly: true)
      try db.execute("""
    drop table  IF EXISTS \(prevTbl);
    alter table \(tbl) rename to \(prevTbl);
    CREATE TABLE IF NOT EXISTS \(tbl)(code, exchange, company, quote, change, updating, marketcap, feature, category);
  """
      )
      try db.execute("begin transaction;")
      let sqlI = try db.prepare("insert into '\(tbl)' values (?, ?, ?, ?, ?, ?, ?, ?, ?);")
      try codeTbl.forEach { e in
        try sqlI.run(e[0], e[2], e[1], "---", "---", "---", e[3], e[4], e[5])
      }
      try db.execute("end transaction;")
    }catch {
      print("Error store2DB for code \(tbl): \(error)")
    }
  }
}
