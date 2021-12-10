//
//  WeatherLocations.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 5/30/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation

struct WeatherLocations {
	static var locations: [Saved] = []

    static var currentConditions: [Int: Current] = [:]
    static var forecasts: [Int: [ForecastData]] = [:]
    static var alerts: [Int: [AlertInfo]] = [:]

    static var stations: [Identifier] = []
}
