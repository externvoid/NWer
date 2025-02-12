// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import SQLite

public enum FetchError: Error {
  case badURL
  case badResponse
  case badJSON
  case someErr
}
public typealias candle = (
  date: String, open: Double, high: Double, low: Double,
  close: Double, volume: Double
)
public typealias record = (
  date: String, open: Double, high: Double, low: Double,
  close: Double, volume: Double, adj: Double
)
typealias Expression = SQLite.Expression

public enum Networker {
  // for SQLite.swift and codeTbl, n225Hist
  static let date = Expression<String>("date")
  static let open = Expression<Double>("open")
  static let high = Expression<Double>("high")
  static let low = Expression<Double>("low")
  static let close = Expression<Double>("close")
  static let volume = Expression<Double>("volume")
  static let adj = Expression<Double>("adj")
  // for crawling.db
  static let code = Expression<String>("code")
  static let company = Expression<String>("company")
  static let exchange = Expression<String>("exchange")
  static let marketcap = Expression<String>("marketcap")
  static let feature = Expression<String>("feature")
  static let category = Expression<String>("category")
  static let name = Expression<String>("name") // e.g. code2024_08_30

  // MARK: CodeTbl
  @available(macOS 12.0, *)
  public static func fetchCodeTbl() async throws -> [[String]] {
    let address = "https://stock.bad.mn/jsonCode2"
    guard let url = URL(string: address) else {
      throw FetchError.badURL
    }
    let request = URLRequest(url: url)
    let (data, res) = try await URLSession.shared.data(for: request)
    guard let res = res as? HTTPURLResponse, res.statusCode < 400
    else {
      throw FetchError.badResponse
    }
    guard let ar = try? JSONSerialization.jsonObject(
      with: data,
      options: []) as? [[Any]] else {
      throw FetchError.badJSON
    }
    puts("OK")
    let codeTbl: [[String]] = ar.map { e in
      let s1 = e[0] as! String
      let s2 = e[1] as! String
      let s3 = e[2] as! String
      let s4 = e[3] as! String
      let s5 = e[4] as! String
      let s6 = e[5] as! String
      let tmp: [String] = [s1, s2, s3, s4, s5, s6] // code .. category
//      let tmp: [String] = [s1, s2, s3]
      return tmp
      //      let s1 = e[0] as! String ,s2 = e[1] as! String; return s1 + ": " + s2
    }

    return codeTbl
  }
  // MARK: Hist
  @available(macOS 12.0, *)
  @MainActor
  public static func fetchHist(_ code: String) async throws-> [candle] {
    let address = "https://stock.bad.mn/jsonS/\(code)"
    guard let url = URL(string: address) else {
      throw FetchError.badURL
    }
    let request = URLRequest(url: url)
    let (data, res) = try await URLSession.shared.data(for: request)
    guard let res = res as? HTTPURLResponse, res.statusCode < 400
    else {
      throw FetchError.badResponse
    }
    guard let ar = try? JSONSerialization.jsonObject(
      with: data,
      options: []) as? [[Any]] else {
      throw FetchError.badJSON
    }
    puts("called fetchHist")
    let hist: [candle] = ar.map { e in // ar: ar of ar
      let date = e[0] as! String
      let open = e[1] as! Double
      let high = e[2] as! Double
      let low = e[3] as! Double
      let close = e[4] as! Double
      let volume = e[5] as! Double
      return (date, open, high, low, close, volume)
    }

    return hist
  }
  // MARK: Sqlite3
  @available(macOS 12.0, *)
  public static func queryHist(_ code: String = "1301",
                               _ dbPath1: String,
                               _ dbPath2: String,
                               _ lim: Int = 60) async throws ->  [candle] {
    var hist: [record] = []
    var dbPath = ""
    if code < "1300" {
      dbPath = dbPath2
    } else {
      dbPath = dbPath1
    }
    print("dbPath: \(dbPath)")
    //    let code = "1301"
    do {
      let db = try Connection(dbPath)
      let t1301 = Table(code)
      let query = t1301.order(date.desc).limit(lim)// .filter(date > "2024-07-18")
      let all = Array(try db.prepare(query))
      hist = all.map { e in
        (e[date], e[open], e[high], e[low], e[close], e[volume], e[adj])
      }
      hist.reverse()
    } catch {
      print(error)
      throw FetchError.someErr
    }

    return hist.map {
      let r = $0.6 / $0.4
      return ($0.0.replacingOccurrences(of: "-", with: "/"),
                       $0.1 * r, $0.2 * r, $0.3 * r, $0.6, $0.5 / r)
//      $0.1, $0.2, $0.3, $0.4, $0.5)
    }
  }
  @available(macOS 12.0, *)
  public static func queryCodeTbl(
    _ dbPath1: String, // codeTbl
    _ dbPath2: String) async throws ->  [[String]] {
    var codeTbl: [[String]] = []
    var n225Tbl: [[String]] = []
    var  dbPath = dbPath1
    var tbl = "codetbl" // using View Table
    do {
      var db = try Connection(dbPath)
      var master = Table(tbl)
      var query = master.order(code.asc)
      var hit = Array(try db.prepare(query))
      codeTbl = hit.map { e in
        [e[code], e[company], e[exchange], e[marketcap], e[feature],
         e[category]]
      }
      dbPath = dbPath2
      db = try Connection(dbPath)
      tbl = "n225Tbl"
      master = Table(tbl)
      query = master.order(code.asc)
      hit = Array(try db.prepare(query))
      n225Tbl = hit.map { e in
        [e[code], e[company], "---", "---", "---", "指数"]
      }
    } catch {
      print(error)
      throw FetchError.someErr
    }

    return n225Tbl + codeTbl
  }
  // 2段階Query, not using View Table
  @available(macOS 12.0, *)
  public static func queryCodeTbl2() async throws ->  [[String]] {
    var codeTbl: [[String]] = []
    let dbPath = "/Volumes/homes/super/NASData/StockDB/yatoday.db"

    let tbl = "sqlite_master"
    do {
      let db = try Connection(dbPath)
      var master = Table(tbl)
      var query = master.order(name.desc)
      let hit = Array(try db.prepare(query)).first![name]
      master = Table(hit)
      query = master.order(code.asc)
      let hit2 = Array(try db.prepare(query))
      codeTbl = hit2.map { e in
        [e[code], e[company], e[exchange], e[marketcap], e[feature],
         e[category]]
      }
    } catch {
      print(error)
      throw FetchError.someErr
    }

    return codeTbl
  }
}
