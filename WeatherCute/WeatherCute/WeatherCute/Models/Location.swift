//
//  Forecast.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 5/29/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation

struct Location: SearchType {
	static var endpoint = Endpoint.location
	var properties: Property
}

struct Property: Codable {
	var gridX: Int
	var gridY: Int
	var cwa: String
}
