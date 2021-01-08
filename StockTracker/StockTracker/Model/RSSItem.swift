//
//  RSSItem.swift
//  StockTracker
//
//  Created by Chenning Li on 12/9/20.
//  Copyright © 2020 Chenning Li. All rights reserved.
//

import Foundation

//MARK: RSSITEM
struct RSSItem:  Codable, CustomDebugStringConvertible {
    
    var id = UUID()
    var description = ""
    var title = ""
    var pubDate = ""
    var guid = ""
    var link = ""
    
    enum CodingKeys: String, CodingKey {
        case description = "description"
        case guid = "guid"
        case link = "link"
        case title = "title"
        case pubDate = "pubDate"
    }
    
    var debugDescription: String { "description = \(description), title = \(title), pubDate = \(pubDate), guid = \(guid), link = \(link)" }
}
