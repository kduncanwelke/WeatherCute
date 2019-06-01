//
//  Forecast.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 5/29/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation

struct Forecast: SearchType {
	static var endpoint = Endpoint.forecast
	var properties: Properties
}

struct Properties: Codable {
	var periods: [ForecastData]
}

struct ForecastData: Codable {
	var name: String
	var isDaytime: Bool
	var temperature: Int
	var shortForecast: String
	var detailedForecast: String
}
