//
//  Current.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 5/29/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation

struct Current: SearchType {
	static var endpoint = Endpoint.current
	var properties: CurrentCondition
}

struct CurrentCondition: Codable {
	var textDescription: String
	var temperature: Temperature
	var dewpoint: DewPoint
	var windChill: WindChill
	var heatIndex: HeatIndex
	var relativeHumidity: Humidity
	var icon: String
}

struct Temperature: Codable {
	var value: Double?
	var unitCode: String
}

struct DewPoint: Codable {
	var value: Double?
	var unitCode: String
}

struct WindChill: Codable {
	var value: Double?
	var unitCode: String
}

struct HeatIndex: Codable {
	var value: Double?
	var unitCode: String
}

struct Humidity: Codable {
	var value: Double?
}
