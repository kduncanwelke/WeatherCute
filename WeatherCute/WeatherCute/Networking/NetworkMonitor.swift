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
    
    static var loadedItems: LoadedItems = .none {
        didSet {
            print(loadedItems)
            if loadedItems == .all {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showNetworkMessage"), object: nil)
            }
        }
    }
    
    enum NetworkStatus {
        case normal
        case lost
        case other
    }
    
    enum LoadedItems {
        case all
        case current
        case currentAndForecast
        case currentAndAlerts
        case forecast
        case forecastAndAlerts
        case alerts
        case none
    }
}
