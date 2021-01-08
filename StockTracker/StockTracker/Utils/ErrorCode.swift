//
//  ErrorCode.swift
//  StockTracker
//
//  Created by Chenning Li on 11/29/20.
//  Copyright © 2020 Chenning Li. All rights reserved.
//

import Foundation

// MARK: - ErrorCode
public struct ErrorCode: Error, Codable {
    public var code: String?
    public var errorDescription: String?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case errorDescription = "description"
    }
    
    public init(code: String?, errorDescription: String?) {
        self.code = code
        self.errorDescription = errorDescription
    }
}
