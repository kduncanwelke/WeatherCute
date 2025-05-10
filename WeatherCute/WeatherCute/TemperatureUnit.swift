//
//  TemperatureUnit.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 6/6/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation

enum TemperatureUnit: String, Hashable, CaseIterable, Identifiable {
	case fahrenheit, celsius
    var id: Self { return self }
    
    var title: String {
        switch self {
        case .fahrenheit:
            return "°F"
        case .celsius:
            return "°C"
        }
    }
}
