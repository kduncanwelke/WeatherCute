//
//  Alert.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 6/6/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation

struct Alert: SearchType {
	static var endpoint = Endpoint.alert
	var features: [AlertInfo]
}

struct AlertInfo: Codable {
	var properties: AlertProperty
}

struct AlertProperty: Codable {
	var areaDesc: String
	var ends: String
	var severity: String
	var certainty: String
	var urgency: String
	var event: String
	var headline: String
	var instruction: String
}
