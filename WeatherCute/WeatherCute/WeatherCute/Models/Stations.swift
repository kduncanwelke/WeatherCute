//
//  Current.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 5/29/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation

struct Stations: SearchType {
	static var endpoint = Endpoint.stations
	var features: [Feature]
}

struct Feature: Codable {
	var properties: Identifier
}

struct Identifier: Codable {
	var stationIdentifier: String
}
