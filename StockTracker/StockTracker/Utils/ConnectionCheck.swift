//
//  InternetConnectionManager.swift
//  StockTracker
//
//  Created by Chenning Li on 11/29/20.
//  Copyright © 2020 Chenning Li. All rights reserved.
//

import Foundation
//Allow applications to access a device’s network configuration settings. Determine the reachability of the device, such as whether Wi-Fi or cell connectivity are active.
import SystemConfiguration

public class ConnectionCheck {
    
    private init() {}
    
    public static func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                //Creates a reachability reference to the specified network address.
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else { return false }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
}

public extension Notification.Name {
    static let internetReachabled = Notification.Name("internetReachabled")
    static let internetNotReachabled = Notification.Name("internetNotReachabled")
}
