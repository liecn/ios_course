//
//  symbolList.swift
//  StockTracker
//
//  Created by Chenning Li on 11/29/20.
//  Copyright © 2020 Chenning Li. All rights reserved.
//

import Foundation

struct SymbolList: Codable, Equatable, Identifiable {
    var id = UUID()
    var name: String
    var symbolsArray: [String]
    var isActive: Bool
    
    init(name: String, symbolsArray: [String], isActive: Bool = true) {
        self.name = name
        self.symbolsArray = symbolsArray
        self.isActive = isActive
    }
    
}
