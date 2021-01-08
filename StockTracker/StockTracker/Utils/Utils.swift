//
//  api.swift
//  StockTracker
//
//  Created by Chenning Li on 11/29/20.
//  Copyright © 2020 Chenning Li. All rights reserved.
//

import Foundation

func storeDefaultsFromSymbolLists(_ list: [SymbolList]) {
    let defaults = UserDefaults.standard
    let listEncoder = JSONEncoder()
    
    do {
        let encodedLists = try listEncoder.encode(list)
        defaults.set(encodedLists, forKey: "DefaultSymbolLists")
    }
    catch {
        debugPrint("error writing to defaults")
    }
}

func getDefaultLists() -> [SymbolList] {
    let defaults = UserDefaults.standard
    if let savedStockAttributes = defaults.object(forKey: "DefaultSymbolLists") as? Data {
        let decoder = JSONDecoder()
        if let array = try? decoder.decode([SymbolList].self, from: savedStockAttributes) {
            return array
        }
    }
    return [SymbolList]()
}
