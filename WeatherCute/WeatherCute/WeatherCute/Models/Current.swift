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
}

struct Temperature: Codable {
	var value: Int
	var unitCode: String
}

struct DewPoint: Codable {
	var value: Int
	var unitCode: String
}

struct WindChill: Codable {
	var value: Int?
	var unitCode: String
}

struct HeatIndex: Codable {
	var value: Int?
	var unitCode: String
}
