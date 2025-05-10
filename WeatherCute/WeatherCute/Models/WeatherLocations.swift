//
//  WeatherLocations.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 5/30/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation

struct WeatherLocations {
	static var loadedLocations: [Saved] = []
    static var locations: [SavedLocation] = []

    static var currentConditions: [String: Current] = [:]
    static var forecasts: [String: [ForecastData]] = [:]
    static var alerts: [String: [AlertInfo]] = [:]

    static var stations: [String: [Identifier]] = [:]
}

struct SavedLocation: Identifiable, Hashable {    
    var name: String
    var latitude: Double
    var longitude: Double
    var xCoord: Int?
    var yCoord: Int?
    var station: String?
    var observationStation: String?
    
    var id: Self { return self }
}
