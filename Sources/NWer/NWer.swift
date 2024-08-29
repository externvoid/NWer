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
typealias Expression = SQLite.Expression

public enum Networker {
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
      let close = e[3] as! Double
      let volume = e[3] as! Double
      return (date, open, high, low, close, volume)
    }

    return hist
  }
  // MARK: Sqlite3
  @available(macOS 12.0, *)
  public static func queryHist(_ code: String = "1301") async throws ->  [candle] {
    var hist: [candle] = []
    //    let dbPath = "/Users/tanaka/Downloads/crawling.db"
    let dbPath = "/Volumes/Public/StockDB/crawling1.db"
    //    let code = "1301"
    do {
      let db = try Connection(dbPath)
      let t1301 = Table(code)
      let date = Expression<String>("date")
      let open = Expression<Double>("open")
      let high = Expression<Double>("high")
      let low = Expression<Double>("low")
      let close = Expression<Double>("close")
      let volume = Expression<Double>("volume")
      let query = t1301.order(date.desc)// .filter(date > "2024-07-18")
      let all = Array(try db.prepare(query))
      hist = all.map { e in
        (e[date], e[open], e[high], e[low], e[close], e[volume])
      }
    } catch {
      print(error)
      throw FetchError.someErr
    }

    return hist
  }
  @available(macOS 12.0, *)
  public static func queryCodeTbl() async throws ->  [[String]] {
    var codeTbl: [[String]] = []
    let dbPath = "/Volumes/Public/StockDB/yatoday.db"

    let tbl = "codetbl"
    do {
      let db = try Connection(dbPath)
      let master = Table(tbl)
      let code = Expression<String>("code")
      let company = Expression<String>("company")
      let exchange = Expression<String>("exchange")
      let marketcap = Expression<String>("marketcap")
      let feature = Expression<String>("feature")
      let category = Expression<String>("category")
      let query = master.order(code.asc)
      let hit = Array(try db.prepare(query))
      codeTbl = hit.map { e in
        [e[code], e[company], e[exchange], e[marketcap], e[feature],
         e[category]]
      }
    } catch {
      print(error)
      throw FetchError.someErr
    }

    return codeTbl
  }
  // 2段階Query
  @available(macOS 12.0, *)
  public static func queryCodeTbl2() async throws ->  [[String]] {
    var codeTbl: [[String]] = []
    let dbPath = "/Volumes/Public/StockDB/yatoday.db"

    let tbl = "sqlite_master"
    do {
      let db = try Connection(dbPath)
      var master = Table(tbl)
      let name = Expression<String>("name")
      //
      let code = Expression<String>("code")
      let company = Expression<String>("company")
      let exchange = Expression<String>("exchange")
      let marketcap = Expression<String>("marketcap")
      let feature = Expression<String>("feature")
      let category = Expression<String>("category")
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
//Networker.queryHist()


