//
//  DetailChartViewController.swift
//  StockTracker
//
//  Created by Chenning Li on 11/29/20.
//  Copyright © 2020 Chenning Li. All rights reserved.
//

import Foundation
import UIKit
import Combine


//MARK: - DETAILMODULES
enum DetailModules: String {
    case assetProfile = "assetProfile"
    case incomeStatementHistory = "incomeStatementHistory"
    case incomeStatementHistoryQuarterly = "incomeStatementHistoryQuarterly"
    case balanceSheetHistory = "balanceSheetHistory"
    case balanceSheetHistoryQuarterly = "balanceSheetHistoryQuarterly"
    case cashflowStatementHistory = "cashflowStatementHistory"
    case cashflowStatementHistoryQuarterly = "cashflowStatementHistoryQuarterly"
    case defaultKeyStatistics = "defaultKeyStatistics"
    case financialData = "financialData"
    case calendarEvents = "calendarEvents"
    case secFilings = "secFilings"
    case recommendationTrend = "recommendationTrend"
    case upgradeDowngradeHistory = "upgradeDowngradeHistory"
    case institutionOwnership = "institutionOwnership"
    case fundOwnership = "fundOwnership"
    case majorDirectHolders = "majorDirectHolders"
    case majorHoldersBreakdown = "majorHoldersBreakdown"
    case insiderTransactions = "insiderTransactions"
    case insiderHolders = "insiderHolders"
    case netSharePurchaseActivity = "netSharePurchaseActivity"
    case earnings = "earnings"
    case earningsHistory = "earningsHistory"
    case earningsTrend = "earningsTrend"
    case industryTrend = "industryTrend"
    case indexTrend = "indexTrend"
    case sectorTrend = "sectorTrend"
}

//MARK: - CHARTVIEWMODEL
class DetailChartViewController: ChartViewProtocol {
    var connectionCheck: Bool {
        didSet {
            if connectionCheck {
                setSubscriptions()
                start()
            } else {
                cancelSubscriptions()
            }
        }
    }
    @Published var period: Period = Period.oneDay {
        didSet { self.historyChartTimerSubject.send() }
        
        willSet {
            switch newValue {
            case .oneDay:
                self.timeInterval = .twoMinit
            case .fiveDays:
                self.timeInterval = .fiveMinit
            case .oneMonth:
                self.timeInterval = .thirtyMinit
            case .sixMonth:
                self.timeInterval = .oneDay
            case .ytd:
                self.timeInterval = .oneDay
            case .oneYear:
                self.timeInterval = .oneDay
            case .fiveYear:
                self.timeInterval = .oneWeak
            case .max:
                self.timeInterval = .threeMonth
            }
        }
    }
    @Published var chart: HistoryChart? {
        didSet {
            self.getChartExtremumsFrom(chart)
            self.getTimeMarkerCount(from: chart)
            self.getElementsForTimeSymbol(from: chart)
        }
    }
    @Published var statistics: Statistics?{
        willSet { if let newPrice = newValue?.optionChain?.result?.first?.quote?.regularMarketPrice { regularPriceNewValue = newPrice }}
    }
    @Published var modules: Modules?
    
    @Published var rss: [RSSItem] = []
    
    // MARK: LOCAL VARS
    var periods = [Period.oneDay, Period.fiveDays, Period.oneMonth, Period.sixMonth, Period.ytd, Period.oneYear, Period.fiveYear, Period.max]
    let symbol: String?
    var elementsForTimeSymbol: [Int]?
    var regularPriceNewValue: Double? = 0.0
    var id: String { return symbol ?? "" }
    var statisticsTimerInterval: Double = 5
    var historyChartTimerInterval: Double = 60
    //    var currentRssUrl: URL?
    
    // MARK: - COMBINE API VARIABLES
    var modulesSubject = PassthroughSubject<Void, WebWrapperError>()
    var statisticsTimerSubject = PassthroughSubject<Void, WebWrapperError>()
    var historyChartTimerSubject = PassthroughSubject<Void, WebWrapperError>()
    //    var rssSubject = PassthroughSubject<Void, WebWrapperError>()
    
    var timersSubscriptions: Set<AnyCancellable> = []
    var modulesSubscription: AnyCancellable?
    var statisticsSubscription: AnyCancellable?
    var historyChartSubscription: AnyCancellable?
    //    var rssSubscription: AnyCancellable?
    
    // MARK: add protocol stubs:
    var session: URLSession?
    var timeInterval: TimeInterval? = .twoMinit
    var chartExtremums: ChartExtremums?
    var timeMarkerCount: Int?
    
    func setSubscriptions() {
        setAndConfigureSession()
        setStatisticsSubscription()
        setHistoryChartSubscription()
        setModulesSubscription()
        //        setRssSubscription()
    }
    
    func cancelSubscriptions() {
        session?.invalidateAndCancel()
        stopTimers()
        statisticsSubscription?.cancel()
        historyChartSubscription?.cancel()
        modulesSubscription?.cancel()
        //        rssSubscription?.cancel()
    }
    
    func start() {
        statisticsTimerSubject.send()
        historyChartTimerSubject.send()
        modulesSubject.send()
        //        rssSubject.send()
        
        Timer.publish(every: statisticsTimerInterval, tolerance: .none, on: RunLoop.main, in: RunLoop.Mode.common, options: nil)
            .autoconnect()
            .sink(receiveCompletion: { _ in }) { [weak self] _ in self?.statisticsTimerSubject.send() }
            .store(in: &timersSubscriptions)
        
        Timer.publish(every: historyChartTimerInterval, tolerance: .none, on: RunLoop.main, in: RunLoop.Mode.common, options: nil)
            .autoconnect()
            .sink(receiveCompletion: { _ in }) { [weak self] _ in self?.historyChartTimerSubject.send() }
            .store(in: &timersSubscriptions)
    }
    
    //MARK: - CONVENIENCE VARIABLES (URL MAKERS)
    private var statisticsURL: URL { WebWrapper.makeStatisticsURL(symbol: self.symbol ?? "", date: Int(Date().timeIntervalSince1970)) }
    private var historyChartURL: URL { WebWrapper.makeHistoryChartURL(symbol: self.symbol ?? "", period: period, interval: timeInterval) }
    //    private var rssURL: URL { WebWrapper.makeRSSURL(symbol: self.symbol ?? "") }
    private var modulesURL: URL { WebWrapper.makeModulesURL(symbol: self.symbol ?? "", modules: [/*.assetProfile, .balanceSheetHistory, .balanceSheetHistoryQuarterly, .calendarEvents, .cashflowStatementHistory, .cashflowStatementHistoryQuarterly,*/ .defaultKeyStatistics, /*.earnings, .earningsHistory, .earningsTrend, .financialData, .fundOwnership, .incomeStatementHistory, .incomeStatementHistoryQuarterly, .indexTrend, .industryTrend, .insiderHolders, .insiderTransactions, .institutionOwnership, .majorDirectHolders, .majorHoldersBreakdown, .netSharePurchaseActivity, .recommendationTrend, .secFilings, .sectorTrend, .upgradeDowngradeHistory*/]) }
    private var statisticsStorageURL: URL? { StorageWrapper.makeDocumentDirectoryURL(forFileNamed: (self.symbol ?? "") + "_STATISTICS") }
    private var historyChartStorageURL: URL? { StorageWrapper.makeDocumentDirectoryURL(forFileNamed: (self.symbol ?? "") + "_HISTORYCHART") }
    
    //MARK: - INIT
    init(withSymbol symbol: String?, connectionCheck: Bool = true) {
        self.symbol = symbol
        self.connectionCheck = connectionCheck
        setSubscriptions()
        if self.connectionCheck {
            start()
        } else {
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(sceneWillDeactivate(notification:)), name: UIScene.willDeactivateNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(sceneDidActivate(notification:)), name: UIScene.didActivateNotification, object: nil)
        
    }
    
    // only for preview
       init(withJSON JSON: String, connectionCheck: Bool = true) {
           self.symbol = JSON
           self.connectionCheck = connectionCheck
           getStatisticsFrom(JSON: JSON)
           getChartFrom(JSON: JSON)
           getRssFrom(XML: JSON)
       }
    
    deinit {
        //debugPrint("               deinit DetailChartViewModel")
    }
    
    @objc func sceneWillDeactivate(notification: Notification) {
        stopTimers()
    }
    
    @objc func sceneDidActivate(notification: Notification) {
        //debugPrint("sceneDidActivate")
        if self.connectionCheck {
            start()
        }
    }
    
    //MARK: funcs
    func stopTimers() {
        timersSubscriptions.forEach { $0.cancel() }
    }
    
    //MARK: - FETCHING (COMBINE API METHODS)
    func setStatisticsSubscription() {
        guard let session = self.session else {return}
        statisticsSubscription =
            statisticsTimerSubject
                .flatMap { _ in
                    WebWrapper.makeNetworkQuery(for: self.statisticsURL, decodableType: Statistics.self, session: session).receive(on: DispatchQueue.main)
            }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure/*(let error)*/:
                    //debugPrint(error)
                    self.setStatisticsSubscription()
                case .finished:
                    //debugPrint("finished")
                    break
                }
            }) { [weak self] statistics in
                self?.statistics = statistics
        }
    }
    
    
    
    
    func setHistoryChartSubscription() {
        
        guard let session = self.session else {return}
        
        historyChartSubscription =
            historyChartTimerSubject
                .flatMap { _ in
                    WebWrapper.makeNetworkQuery(for: self.historyChartURL, decodableType: HistoryChart.self, session: session).receive(on: DispatchQueue.main)
            }
            .sink(receiveCompletion: {completion in
                switch completion {
                case .failure/*(let error)*/:
                    //debugPrint(error)
                    self.setHistoryChartSubscription()
                case .finished:
                    //debugPrint("finished")
                    break
                }
            }) { [weak self] historicalChart in self?.chart = historicalChart }
    }
    
    //    func setRssSubscription() {
    //
    //        guard let session = self.session else {return}
    //
    //        rssSubscription = rssSubject
    //            .flatMap { _ in
    //                WebService.makeNetworkQueryForXML(for: self.rssURL, session: session).receive(on: DispatchQueue.main)
    //        }
    //        .sink(receiveCompletion: { completion in
    //        }) { [weak self] rss in self?.rss = rss }
    //    }
    
    func setModulesSubscription() {
        
        guard let session = self.session else {return}
        
        modulesSubscription =
            modulesSubject
                .flatMap { _ in
                    WebWrapper.makeNetworkQuery(for: self.modulesURL, decodableType: Modules.self, session: session).receive(on: DispatchQueue.main)
            }
            .sink(receiveCompletion: {completion in
                //                switch completion {
                //                case .failure(let error):
                //                    debugPrint(error)
                //                case .finished:
                //                    debugPrint("finished")
                //                }
            }) { [weak self] modules in self?.modules = modules }
    }
    
    //MARK: - FETCHING (VANILLA API)
     
     func getChartFrom(JSON: String) {
         self.timeInterval = .oneMinit
         if let url = StorageWrapper.makeBandleURL(forJSONNamed: JSON + "_chart") {
             
             try! StorageWrapper.readData(from: url, decodableType: HistoryChart.self) { chart in
                 self.chart = chart
             }
         }
     }
     
     func getStatisticsFrom(JSON: String) {
         self.timeInterval = .oneMinit
         if let url = StorageWrapper.makeBandleURL(forJSONNamed: JSON + "_statistics") {
             
             try! StorageWrapper.readData(from: url, decodableType: Statistics.self) { chart in
                 self.statistics = chart
             }
         }
     }
    
     func getRssFrom(XML: String) {
         if let url = StorageWrapper.makeBandleURL(forXMLNamed: XML) {
             StorageWrapper.readXML(url: url) { rss in
                 self.rss = rss
             }
         }
     }
     
     func getRss(for XML: String) {
         StorageWrapper.makeStoreQuery(XML: XML) { data in
             let parser = XmlRssParser()
             let rssItems = parser.parsedItemsFromData(data)
             self.rss = rssItems
         }
     }
    
    //MARK: - PRIVATE METHODS
    private func getElementsForTimeSymbol(from historyChart: HistoryChart?) {
        switch self.period {
        case .oneDay:
            self.elementsForTimeSymbol = compressedArrayFor(timeComponent: Calendar.Component.hour)
        case .fiveDays:
            self.elementsForTimeSymbol = compressedArrayFor(timeComponent: Calendar.Component.day)
        case .oneMonth:
            self.elementsForTimeSymbol = compressedArrayFor(timeComponent: Calendar.Component.day)
        case .sixMonth:
            self.elementsForTimeSymbol = compressedArrayFor(timeComponent: Calendar.Component.month)
        case .ytd:
            self.elementsForTimeSymbol = compressedArrayFor(timeComponent: Calendar.Component.month)
        case .oneYear:
            self.elementsForTimeSymbol = compressedArrayFor(timeComponent: Calendar.Component.month)
        case .fiveYear:
            self.elementsForTimeSymbol = compressedArrayFor(timeComponent: Calendar.Component.year)
        case .max:
            self.elementsForTimeSymbol = compressedArrayFor(timeComponent: Calendar.Component.year)
        }
    }
    private func compressedArrayFor(timeComponent: Calendar.Component) -> [Int] {
        guard let timeStamp = self.chart?.chart?.result?.first??.timestamp, let timeZone = self.chart?.chart?.result?.first??.meta?.timezone else {return []}
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: timeZone) ?? TimeZone(abbreviation: "UTC")!
        
        var rowArray = [Int]()
        let currentMinIndex = 0
        rowArray.append(currentMinIndex)
        let currentDate = Date(timeIntervalSince1970: Double(timeStamp[currentMinIndex]))
        var currentPeriod = calendar.dateComponents([timeComponent], from: currentDate).value(for: timeComponent)
        
        for index in Array(0...timeStamp.count - 1) {
            let date = Date(timeIntervalSince1970: Double(timeStamp[index]))
            let period = calendar.dateComponents([timeComponent], from: date).value(for: timeComponent)
            if period != currentPeriod {
                rowArray.append(index)
                currentPeriod = period
            }
        }
        
        switch self.period {
        case .oneDay, .oneYear:
            rowArray = Array(rowArray.dropFirst())
        case .oneMonth:
            rowArray = Array(rowArray.filter { index in
                let date = Date(timeIntervalSince1970: Double(timeStamp[index]))
                let dateComponentsWeekday = calendar.dateComponents([.weekday], from: date).weekday
                return dateComponentsWeekday == 5 })
        case .max:
            rowArray = Array(rowArray.filter { index in
                let date = Date(timeIntervalSince1970: Double(timeStamp[index]))
                let dateComponentsYear = calendar.dateComponents([.year], from: date).year
                return (dateComponentsYear! % 5) == 0
            }.dropLast())
        default: break
        }
        
        if rowArray.count > 6 {
            var newArray: [Int] = []
            for i in 0..<rowArray.count {
                if i % 2 != 0 {
                    newArray.append(rowArray[i])
                }
            }
            rowArray = newArray
        }
        return rowArray
    }
    
}
