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

