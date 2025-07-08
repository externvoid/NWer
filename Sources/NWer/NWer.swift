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
public typealias record2 = (
  date: String, open: Double, high: Double, low: Double,
  close: Double, volume: Double
)
typealias Expression = SQLite.Expression
//let db = try! Connection("crawling.db")
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
  static var db: Connection! // = try! Connection()
  // static func NWer_init

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
  // MARK: Mod
  @available(macOS 12.0, *) // 2025-06-19Th
  public static func queryHist(_ code: String = "1301", _ P1: String, _ P2: String,
                               _ lim: Int = 60) async throws -> [candle] {
    var hist: [record2] = []
//    let hist: [record] = []
    let sub = code < "1300" ? "n225" : "sub"
    print("code@NWer: \(code)")

    return try await withCheckedThrowingContinuation { continuation in
      serialQueue.async {
        do {
          let query = """
            SELECT 
              REPLACE(date, '-', '/') AS date,
              open * rate AS adj_open,
              high * rate AS adj_high,
              low * rate AS adj_low,
              adj,
              volume / rate AS adj_volume
               FROM (
                SELECT *,
                adj * 1.0 / close AS rate
                FROM \(sub).'\(code)'
                ORDER BY date DESC
                LIMIT \(lim)
              )
            ORDER BY date ASC;
            """

          for e in try db.prepare(query) {
            hist.append((e[0] as! String, e[1] as! Double, e[2] as! Double,
                         e[3] as! Double, e[4] as! Double, e[5] as! Double))
          }

          continuation.resume(returning: hist)
        } catch {
          print("NWer.queryHist: \(error)") //, RetryCnt: \(currentRetryCount)")
          continuation.resume(throwing: FetchError.someErr)
        } // do
      }
    } // withChecked
  }

  // !!!: Mod
  @available(macOS 12.0, *)
  public static func queryCodeTbl( _ p1: String, _ p2: String) async throws
  ->  [[String]] {
      var codeTbl: [[String]] = []
      var n225Tbl: [[String]] = []
      // !!!: step 1
      var tbl = "codetbl" // using View Table
      do {
        let sql = """
          SELECT * FROM \(tbl)
          WHERE code IN (
          SELECT name FROM sub.sqlite_master WHERE type = 'table'
          ) order by code;
          """
        for e in try db.prepare(sql) { // code, exchange, company...
          codeTbl.append([e[0] as! String, e[2] as! String, e[1] as! String,
                         e[6] as! String, e[7] as! String, e[8] as! String])
        }
        // !!!: step 2
        tbl = "n225Tbl"
        let sql2 = """
          SELECT * FROM n225.\(tbl) order by code;
          """
        for e in try db.prepare(sql2) {
          n225Tbl.append([e[0] as! String, "---", e[1] as! String,  "---", "---", "指数"])
        }
      } catch {
        print("\(error), might be an app sandbox setting issue")
        throw FetchError.someErr
      }

      return n225Tbl + codeTbl
    }
}
