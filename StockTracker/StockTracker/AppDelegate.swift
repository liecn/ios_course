//
//  AppDelegate.swift
//  StockTracker
//
//  Created by Chenning Li on 11/16/20.
//  Copyright © 2020 Chenning Li. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let defaultLists = [
        SymbolList(name: "EQUITIES", symbolsArray: ["AAPL", "GOOG", "FB", "AMZN"], isActive: true),
        SymbolList(name: "CRYPTOCURRENCIES", symbolsArray: ["BTC-USD"], isActive: true),
        SymbolList(name: "INDEXES", symbolsArray: ["^DJI", "^GSPC"], isActive: true),
    ]
    
    func isAppAlreadyLaunchedOnce() -> Bool {
        //An interface to the user’s defaults database, where you store key-value pairs persistently across launches of your app.
        let defaults = UserDefaults.standard
        if defaults.string(forKey: "isAppAlreadyLaunchedOnce") != nil {
            //debugPrint("App already launched sometimes")
            return true
        } else {
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            //debugPrint("App launched first time")
            return false
        }
    }
    
    
    // Back4App
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if !isAppAlreadyLaunchedOnce() { storeDefaultsFromSymbolLists(defaultLists) }
        let parseConfig = ParseClientConfiguration {
                $0.applicationId = "FX4QYDb2Tddk2iIYt8w78kzGvLpgwyhQ0S6Wk67l" // <- UPDATE
                $0.clientKey = "wsIuR2NLkci1x2OQfZHU2EMeZ2onyLSO8ypXt3Py" // <- UPDATE
                $0.server = "https://parseapi.back4app.com"
        }
        Parse.initialize(with: parseConfig)
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

