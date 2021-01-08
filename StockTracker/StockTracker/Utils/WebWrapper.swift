//
//  webWrapper.swift
//  StockTracker
//
//  Created by Chenning Li on 11/29/20.
//  Copyright © 2020 Chenning Li. All rights reserved.
//

import Foundation
import Combine

//MARK: - WEBWRAPPER ERROR
enum WebWrapperError: Error, LocalizedError {
    case unknown
    case apiError(from: APIError)
    case parserError(from: DecodingError)
    case networkError(from: URLError)
    
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown error"
        case .apiError(let from):
            return from.errorDescription
        case .parserError(let from):
            return from.localizedDescription
        case .networkError(let from):
            return from.localizedDescription
        }
    }
}

//MARK: - API ERROR
enum APIError: Error, LocalizedError {
    case unknown
    case apiError(reason: String)
    
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown API error"
        case .apiError(let reason):
            return reason
        }
    }
}

enum WebWrapper {
    //MARK: - URL
    static func makeModulesURL(symbol: String, modules: [DetailModules]) -> URL {
        let symbols = symbol.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        let modules = modules.map{$0.rawValue}.joined(separator: "%2C")
        let urlComponents = URLComponents(string: "https://query1.finance.yahoo.com/v10/finance/quoteSummary/\(symbols)?modules=\(modules)")
        return (urlComponents?.url)!
        
        // let url = makeModulesURL(symbol: "AAPL", modules: [.assetProfile, .balanceSheetHistory, .balanceSheetHistoryQuarterly, .calendarEvents, .cashflowStatementHistory, .cashflowStatementHistoryQuarterly, .defaultKeyStatistics, .earnings, .earningsHistory, .earningsTrend, .financialData, .fundOwnership, .incomeStatementHistory, .incomeStatementHistoryQuarterly, .indexTrend, .industryTrend, .insiderHolders, .insiderTransactions, .institutionOwnership, .majorDirectHolders, .majorHoldersBreakdown, .netSharePurchaseActivity, .recommendationTrend, .secFilings, .sectorTrend, .upgradeDowngradeHistory])
    }
    
    static func makeHistoryChartURL(symbol: String, period: Period? = nil, interval: TimeInterval? = TimeInterval.oneDay, start: Int? = nil, end: Int? = nil) -> URL {
        
        let symbols = symbol.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        var urlComponents = URLComponents(string: "https://query1.finance.yahoo.com/v8/finance/chart/\(symbols)")
        urlComponents?.queryItems = [
            URLQueryItem(name: "interval", value: interval?.rawValue),
            //URLQueryItem(name: "events", value: "div,splits"),   //URLQueryItem(name: "includePrePost", value: "true"), // add Pre, Post and Regular   //URLQueryItem(name: "precision", value: "false")   //URLQueryItem(name: "backadjust", value: "false"),   //URLQueryItem(name: "autoadjust", value: "false"),
            //https://query1.finance.yahoo.com/v8/finance/chart/AAPL?symbol=AAPL&period1=0&period2=9999999999&interval=1d&includePrePost=true&events=div%2Csplit
        ]
        
        if period == nil {
            if start == nil {
                urlComponents?.queryItems?.append(URLQueryItem(name: "period1", value: "-2208988800"))
            } else {
                urlComponents?.queryItems?.append(URLQueryItem(name: "period1", value: "\(start!)"))
            }
            
            if end == nil {
                urlComponents?.queryItems?.append(URLQueryItem(name: "period2", value: String(Date().timeIntervalSince1970)))
            } else {
                urlComponents?.queryItems?.append(URLQueryItem(name: "period2", value: "\(end!)"))
            }
        } else {
            urlComponents?.queryItems?.append(URLQueryItem(name: "range", value: period?.rawValue))
        }
        
        return (urlComponents?.url)!
    }
    
    static func makeStatisticsURL(symbol: String, date: Int? = nil) -> URL {
        let symbols = symbol.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        var urlComponents = URLComponents(string: "https://query1.finance.yahoo.com/v7/finance/options/\(symbols)")
        /////      https://query1.finance.yahoo.com/v7/finance/quote?symbols=aapl
        urlComponents?.queryItems = []
        
        if date != nil {
            urlComponents?.queryItems?.append(URLQueryItem(name: "date", value: "\(date!)"))
        }
        
        return (urlComponents?.url)!
    }
    
    static func makeRSSURL(symbol: String) -> URL {
        let symbols = symbol.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        let urlComponents = URLComponents(string: "https://feeds.finance.yahoo.com/rss/2.0/headline?s=\(symbols)&region=US&lang=en-US&format=json")
        return (urlComponents?.url)!
    }
    
    static func makeSearchURL(index: String) -> URL {
        let symbols = index.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        return URL(string: "https://finance.yahoo.com/_finance_doubledown/api/resource/searchassist;searchTerm=\(symbols)?device=console&returnMeta=true")!
        
    }
    
    //MARK: -QUERY (COMBINE)
    
    
    static func makeNetworkQuery<T: Codable>(for url: URL, decodableType: T.Type, session: URLSession) -> AnyPublisher<T, WebWrapperError> {
        
        return session.dataTaskPublisher(for: url)
            .tryMap({ data, response in
                guard let httpResponse = response as? HTTPURLResponse else { throw APIError.unknown }
                switch httpResponse.statusCode {
                case 401: throw APIError.apiError(reason: "Unauthorized")
                case 403: throw APIError.apiError(reason: "Resource forbidden")
                case 404: throw APIError.apiError(reason: "Resource not found")
                case 405..<500: throw APIError.apiError(reason: "client error")
                case 501..<600: throw APIError.apiError(reason: "server error")
                    
                default: break
                }
                
                //print(String(data: data, encoding: String.Encoding.utf8)!)
                //debugPrint(url)
                return data
            })
            //.receive(on: DispatchQueue.main)
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError({ error in
                switch error {
                case let error as DecodingError:
                    return .parserError(from: error)//.parserError(from: decError.failureReason)
                case let error as URLError:
                    return .networkError(from: error)
                case let error as APIError:
                    return .apiError(from: error)
                default:
                    return .unknown
                }
            })
            //.catch { _ in Empty<T, WebServiceError>() }
            .eraseToAnyPublisher()
    }
    
    
    
    static func makeNetworkQuery<T: Codable>(for url: URL, decodableType: T.Type) -> AnyPublisher<T, WebWrapperError> {
        
        //let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 10)
        //let configuration = URLSessionConfiguration.default
        //configuration.waitsForConnectivity = true
        //let session = URLSession(configuration: configuration)
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap({ data, response in
                guard let httpResponse = response as? HTTPURLResponse else { throw APIError.unknown }
                switch httpResponse.statusCode {
                case 401: throw APIError.apiError(reason: "Unauthorized")
                case 403: throw APIError.apiError(reason: "Resource forbidden")
                case 404: throw APIError.apiError(reason: "Resource not found")
                case 405..<500: throw APIError.apiError(reason: "client error")
                case 501..<600: throw APIError.apiError(reason: "server error")
                    
                default: break
                }
                if decodableType == HistoryChart.self {
                    //print(String(data: data, encoding: String.Encoding.utf8)!)
                }
                //print(String(data: data, encoding: String.Encoding.utf8)!)
                return data
            })
            //.receive(on: DispatchQueue.main)
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError({ error in
                switch error {
                case let error as DecodingError:
                    return .parserError(from: error)//.parserError(from: decError.failureReason)
                case let error as URLError:
                    return .networkError(from: error)
                case let error as APIError:
                    return .apiError(from: error)
                default:
                    return .unknown
                }
            })
            //.catch { _ in Empty<T, WebServiceError>() }
            .eraseToAnyPublisher()
    }
    static func makeNetworkQueryForXML(for url: URL, session: URLSession) -> AnyPublisher<[RSSItem], WebWrapperError> {
        session.dataTaskPublisher(for: url)
            .tryMap({ data, response in
                guard let httpResponse = response as? HTTPURLResponse else { throw APIError.unknown }
                switch httpResponse.statusCode {
                case 401: throw APIError.apiError(reason: "Unauthorized")
                case 403: throw APIError.apiError(reason: "Resource forbidden")
                case 404: throw APIError.apiError(reason: "Resource not found")
                case 405..<500: throw APIError.apiError(reason: "Client error")
                case 501..<600: throw APIError.apiError(reason: "Server error")
                default: break
                }
                let parser = XmlRssParser()
                let rssItems = parser.parsedItemsFromData(data)
                return rssItems
            })
            .mapError({ error in
                //debugPrint(error.localizedDescription)
                switch error {
                case let error as DecodingError:
                    return .parserError(from: error)
                case let error as URLError:
                    return .networkError(from: error)
                case let error as APIError:
                    return .apiError(from: error)
                default:
                    return .unknown
                }
            })
            .eraseToAnyPublisher()
    }
    
    
    
    static func makeNetworkQueryForXML(for url: URL) -> AnyPublisher<[RSSItem], WebWrapperError> {
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap({ data, response in
                guard let httpResponse = response as? HTTPURLResponse else { throw APIError.unknown }
                switch httpResponse.statusCode {
                case 401: throw APIError.apiError(reason: "Unauthorized")
                case 403: throw APIError.apiError(reason: "Resource forbidden")
                case 404: throw APIError.apiError(reason: "Resource not found")
                case 405..<500: throw APIError.apiError(reason: "Client error")
                case 501..<600: throw APIError.apiError(reason: "Server error")
                default: break
                }
                let parser = XmlRssParser()
                let rssItems = parser.parsedItemsFromData(data)
                return rssItems
            })
            .mapError({ error in
                //debugPrint(error.localizedDescription)
                switch error {
                case let error as DecodingError:
                    return .parserError(from: error)
                case let error as URLError:
                    return .networkError(from: error)
                case let error as APIError:
                    return .apiError(from: error)
                default:
                    return .unknown
                }
            })
            .eraseToAnyPublisher()
    }
    
    static func makeNetworkQueryForXMLXML(for url: URL) -> AnyPublisher<[RSSItem], WebWrapperError> {
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap({ data, response in
                guard let httpResponse = response as? HTTPURLResponse else { throw APIError.unknown }
                switch httpResponse.statusCode {
                case 401: throw APIError.apiError(reason: "Unauthorized")
                case 403: throw APIError.apiError(reason: "Resource forbidden")
                case 404: throw APIError.apiError(reason: "Resource not found")
                case 405..<500: throw APIError.apiError(reason: "Client error")
                case 501..<600: throw APIError.apiError(reason: "Server error")
                default: break
                }
                return data
            })
            .flatMap({ data in
                XMLPublisher(data: data)
            })
            .mapError({ error in
                //debugPrint(error.localizedDescription)
                switch error {
                case let error as DecodingError:
                    return .parserError(from: error)//.parserError(from: decError.failureReason)
                case let error as URLError:
                    return .networkError(from: error)
                case let error as APIError:
                    return .apiError(from: error)
                default:
                    return .unknown
                }
            })
            .eraseToAnyPublisher()
    }
    
}
