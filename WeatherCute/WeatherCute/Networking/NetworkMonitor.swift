//
//  NetworkMonitor.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 3/13/20.
//  Copyright © 2020 Kate Duncan-Welke. All rights reserved.
//

import Foundation
import Network

struct NetworkMonitor {
    
    static let monitor = NWPathMonitor()
    static var connection = true
    
    static var status: NetworkStatus = .normal
    
    static var messageShown = false
    
    enum NetworkStatus {
        case normal
        case lost
        case other
    }
}
