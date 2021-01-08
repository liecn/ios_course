//
//  ChartViewController.swift
//  StockTracker
//
//  Created by Chenning Li on 11/29/20.
//  Copyright © 2020 Chenning Li. All rights reserved.
//

import Foundation
import Combine

enum Mode {
    case active
    case passive
    case waiting
    case hidden
    case remove
}

class ChartViewController: ChartViewProtocol {
    @Published var period: Period = Period.oneDay
    
    @Published var chart: HistoryChart? {
        didSet {
            self.getChartExtremumsFrom(chart)
            self.getTimeMarkerCount(from: chart)
        }
    }
    
    @Published var statistics: Statistics?{
        willSet { if let newPrice = newValue?.optionChain?.result?.first?.quote?.regularMarketPrice { regularPriceNewValue = newPrice }}
        didSet {
        }
    }
    
    //MARK: add protocol stubs:
    var session: URLSession?
    var timeInterval: TimeInterval? = .fiveMinit
    var chartExtremums: ChartExtremums?
    var timeMarkerCount: Int?
    
    func setSubscriptions() {
        setAndConfigureSession()
        setStatisticsSubscription()
        setHistoryChartSubscription()
    }
    
    func cancelSubscriptions() {
        session?.invalidateAndCancel()
        stopTimers()
        statisticsSubscription?.cancel()
        historyChartSubscription?.cancel()
    }
    
    func start() {
        statisticsTimerSubject.send()
        historyChartTimerSubject.send()
        
        Timer.publish(every: statisticsTimerInterval, tolerance: .none, on: RunLoop.main, in: RunLoop.Mode.common, options: nil)
            .autoconnect()
            .sink(receiveCompletion: { _ in }) { [weak self] _ in self?.statisticsTimerSubject.send() }
            .store(in: &timersSubscriptions)
        
        Timer.publish(every: historyChartTimerInterval, tolerance: .none, on: RunLoop.main, in: RunLoop.Mode.common, options: nil)
            .autoconnect()
            .sink(receiveCompletion: { _ in }) { [weak self] _ in self?.historyChartTimerSubject.send() }
            .store(in: &timersSubscriptions)
    }
    
    //MARK: local vars:
    var mode: Mode = .passive {
        didSet {
            switch mode {
            case .active:
                if oldValue == .passive {
                    setSubscriptions()
                    start()
                } else {
                    start()
                }
            //debugPrint("set ACTIVE")
            case .passive:
                if oldValue == .active || oldValue == .hidden || oldValue == .waiting {
                    cancelSubscriptions()
                }
            //debugPrint("set PASSIVE")
            case .waiting:
                if oldValue == .active {
                    stopTimers()
                } else {
                    setSubscriptions()
                }
            //debugPrint("set WAITING")
            case .hidden:
                if oldValue == .active {
                    stopTimers()
                } else if oldValue == .passive {
                    setSubscriptions()
                }
            //debugPrint("set HIDDEN")
            case .remove:
                stopTimers()
                cancelSubscriptions()
                //debugPrint("set REMOVE")
            }
        }
    }
    
    var connectionCheck: Bool {
        didSet {
            if connectionCheck {
                if mode == .passive || mode == .waiting {
                    mode = .active
                }
            } else {
                if mode == .active {
                    mode = .passive
                }
            }
        }
    }
    
    var symbol: String?
    var regularPriceNewValue: Double? = 0.0
    var id: String { return symbol ?? "" }
    var statisticsTimerInterval: Double = 15
    var historyChartTimerInterval: Double = 60
    
    var statisticsTimerSubject = PassthroughSubject<Void, WebWrapperError>()
    var historyChartTimerSubject = PassthroughSubject<Void, WebWrapperError>()
    
    //A type-erasing cancellable object that executes a provided closure when canceled.
    var timersSubscriptions: Set<AnyCancellable> = []
    var statisticsSubscription: AnyCancellable?
    var historyChartSubscription: AnyCancellable?
    
    //MARK: - CONVENIENCE VARIABLES (URL MAKERS)
    private var statisticsURL: URL { WebWrapper.makeStatisticsURL(symbol: self.symbol ?? "", date: Int(Date().timeIntervalSince1970)) }
    private var historyChartURL: URL { WebWrapper.makeHistoryChartURL(symbol: self.symbol ?? "", period: period, interval: timeInterval) }
    
    private var statisticsStorageURL: URL? { StorageWrapper.makeDocumentDirectoryURL(forFileNamed: (self.symbol ?? "") + "_STATISTICS") }
    private var historyChartStorageURL: URL? { StorageWrapper.makeDocumentDirectoryURL(forFileNamed: (self.symbol ?? "") + "_HISTORYCHART") }
    
    
    // init:
    init(withSymbol symbol: String?, connectionCheck: Bool = true) {
        self.symbol = symbol
        self.connectionCheck = connectionCheck
        fetchStatisticsFromDisc()
    }
    
    // only for preview
    init(withJSON JSON: String, connectionCheck: Bool = true) {
        self.symbol = JSON
        self.connectionCheck = connectionCheck
        getStatisticsFrom(JSON: JSON)
        getChartFrom(JSON: JSON)
    }
    
    deinit {
        debugPrint("deinit DetailChartViewController")
    }
    
    func setAndConfigureSession() {
        let configuration = URLSessionConfiguration.default
        session = URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
    }
    
    //funcs:
    func stopTimers() {
        timersSubscriptions.forEach { $0.cancel() }
    }
    
    // MARK: - STORING (VANILLA API)
    func storeStatisticsToDisc() {
        guard let url = self.statisticsStorageURL else {return}
        do {
            try StorageWrapper.storeData(self.statistics, url: url)
        } catch { }
    }
    
    func storeHistoryChartToDisc() {
        guard let url = self.historyChartStorageURL else {return}
        do {
            try StorageWrapper.storeData(self.chart, url: url)
        } catch { }
    }
    
    func fetchStatisticsFromDisc()  {
        guard let url = self.statisticsStorageURL else {return}
        do {
            try StorageWrapper.readData(from: url, decodableType: Statistics.self) { statistics in
                self.statistics = statistics
            }
        } catch /*let error*/ {
            //            switch error {
            //            case let error as StorageError:
            //                debugPrint(error.errorDescription!)
            //            default:
            //                debugPrint(error.localizedDescription)
            //            }
        }
    }
    
    func fetchHistoryChartFromDisc()  {
        guard let url = self.historyChartStorageURL else {return}
        do {
            try StorageWrapper.readData(from: url, decodableType: HistoryChart.self) { historyChart in
                //debugPrint("SUCCESS READING FROM DISC...")
            }
        } catch /*let error*/ {
            //            switch error {
            //            case let error as StorageError:
            //                debugPrint(error.errorDescription!)
            //            default:
            //                debugPrint(error.localizedDescription)
            //            }
        }
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
            try! StorageWrapper.readData(from: url, decodableType: Statistics.self) { statistics in
                self.statistics = statistics
            }
        }
        else{
            let url = StorageWrapper.makeBandleURL(forJSONNamed: JSON + "_statistics")
            self.symbol=url?.absoluteString
        }
    }
    
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
                
            }) { [weak self] historyChart in
                self?.chart = historyChart }
    }
    
    
}
