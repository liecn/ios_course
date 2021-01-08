//
//  MainViewController.swift
//  StockTracker
//
//  Created by Chenning Li on 11/29/20.
//  Copyright © 2020 Chenning Li. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

// ObservableObject: A type of object with a publisher that emits before the object has changed.
// Identifiable: A class of types whose instances hold the value of an entity with stable identity.
class MainViewController: ObservableObject, Identifiable{
    
    @Published var symbolLists: [SymbolList] = [] {
        didSet {
            storeDefaultsFromSymbolLists(symbolLists)
        }
    }
    
    @Published var chartViewControllers: [ChartViewController] = []
    
    @Published var rss: [RSSItem] = []
    
    @Published var connectionCheck: Bool {
        didSet {
            if let detailViewController = self.detailViewController {
                detailViewController.connectionCheck = self.connectionCheck
            } else {
                self.chartViewControllers.forEach{ $0.connectionCheck = self.connectionCheck}
            }
            
            if self.connectionCheck {
                self.start()
            }
        }
    }
    
    //MARK: LOCAL VARS
    var detailViewController: DetailChartViewController?
    var currentRssUrl: URL?
    var rssSymbols: String {
        var array: [[String]] = []
        for list in self.symbolLists {
            array.append(list.symbolsArray)
        }
        return array.flatMap { $0 }.joined(separator: ",")
        
    }
    
    private var rssURL: URL { WebWrapper.makeRSSURL(symbol: self.rssSymbols ) }
    
    var rssSubscription: AnyCancellable?
    var rssSubject = PassthroughSubject<Void, WebWrapperError>()
    
    //init
    init() {
        self.symbolLists = [SymbolList]()
        self.chartViewControllers = [ChartViewController]()
        self.connectionCheck = true
    }
    
    // ONLY FOR PRESENTATION:
    init(from JSON: String) {
        var chartViewControllers: [ChartViewController] = []
        self.symbolLists = [SymbolList(name: "My List", symbolsArray: [JSON], isActive: true)]
        let viewController = ChartViewController(withJSON: JSON)
        chartViewControllers.append(viewController)
        self.chartViewControllers = chartViewControllers
        self.connectionCheck = true
    }
    
    init(from symbolLists: [SymbolList], connectionCheck: Bool = true) {
        self.symbolLists = symbolLists
        self.connectionCheck = connectionCheck
        var chartViewControllers: [ChartViewController] = []
        for list in self.symbolLists {
            for symbol in list.symbolsArray {
                let viewController = ChartViewController(withSymbol: symbol, connectionCheck: self.connectionCheck)
                
                if connectionCheck {
                    viewController.mode = list.isActive ? .active : .hidden
                } else {
                    viewController.mode = list.isActive ? .waiting : .hidden
                }
                
                chartViewControllers.append(viewController)
            }
        }
        
        self.chartViewControllers = chartViewControllers
        
        setRssSubscription()
        
        if self.connectionCheck {
            start()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(sceneWillDeactivate(notification:)), name: UIScene.willDeactivateNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(sceneDidActivate(notification:)), name: UIScene.didActivateNotification, object: nil)
        
        checkInternetAvailabilityIfChangedPreviousValue(connectionCheck)
        
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: RSS FOR NEWS
    func setRssSubscription() {
        rssSubscription = rssSubject
            .flatMap { _ in WebWrapper.makeNetworkQueryForXML(for: self.rssURL).receive(on: DispatchQueue.main)}
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    debugPrint(error)
                case .finished:
                    break
                }
            }) { rss in self.rss = rss }
    }
    func cancelSubscriptions() {
        rssSubscription?.cancel()
    }
    
    func start() {
        rssSubject.send()
    }
    
    //MARK: STATUS OF STOCKS FOR NETWORK CONNECTION
    @objc func sceneWillDeactivate(notification: Notification) {
        self.chartViewControllers.forEach {
            $0.storeStatisticsToDisc()
            if $0.mode == .active {
                $0.mode = .waiting
            }
            
        }
        
    }
    
    @objc func sceneDidActivate(notification: Notification) {
        self.chartViewControllers.forEach {
            
            if self.connectionCheck {
                if $0.mode == .waiting {
                    $0.mode = .active
                }
            }
        }
    }
    func checkInternetAvailabilityIfChangedPreviousValue(_ previousValue: Bool) {
        let currentValue = ConnectionCheck.isConnectedToNetwork()
        if !previousValue && currentValue {
            self.connectionCheck = true
        } else if previousValue && !currentValue {
            self.connectionCheck = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.checkInternetAvailabilityIfChangedPreviousValue(self.connectionCheck)
        }
    }
    
    //MARK: RETURN THE CHARTVIEWCONTROLER WITH ID
    func modelWithId(_ id: String) -> ChartViewController {
        
        for index in 0..<self.chartViewControllers.count {
            if self.chartViewControllers[index].id == id {
                return chartViewControllers[index]
            }
        }
        return ChartViewController(withSymbol: "")
    }
    
    func addNewModelWithSymbol(_ symbol: String, from detailViewController: DetailChartViewController, toListWithIndex index: Int) {
        
        let newViewController = ChartViewController(withSymbol: symbol)
        
        if self.connectionCheck {
            if self.symbolLists[index].isActive {
                newViewController.mode = .active
            } else {
                newViewController.mode = .hidden
            }
        } else {
            newViewController.mode = .waiting
        }
        
        newViewController.statistics = self.detailViewController?.statistics
        
        self.chartViewControllers.append(newViewController)
    }
    
}
