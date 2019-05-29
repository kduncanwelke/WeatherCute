//
//  Endpoint.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 5/29/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation

enum Endpoint {
	case location
	case forecast
	case stations
	case current

	private var baseURL: URL {
		return URL(string: "https://api.weather.gov/")!
	}
	
	// generate url based on type
	func url() -> URL {
		switch self {
		case .location:
			let latitude = LocationSearch.latitude
			let longitude = LocationSearch.longitude
			
			let components = URLComponents(url: baseURL.appendingPathComponent("points/\(latitude),\(longitude)"), resolvingAgainstBaseURL: false)
			
			return components!.url!
		case .forecast:
			let x = ForecastSearch.gridX
			let y = ForecastSearch.gridY
			let station = ForecastSearch.station
			
			let components = URLComponents(url: baseURL.appendingPathComponent("gridpoints/\(station)/\(x),\(y)/forecast"), resolvingAgainstBaseURL: false)
			
			return components!.url!
		case .stations:
			let x = ForecastSearch.gridX
			let y = ForecastSearch.gridY
			let station = ForecastSearch.station
			
			let components = URLComponents(url: baseURL.appendingPathComponent("gridpoints/\(station)/\(x),\(y)/stations"), resolvingAgainstBaseURL: false)
			
			return components!.url!
		case .current:
			let observation = ForecastSearch.observationStation
			
			let components = URLComponents(url: baseURL.appendingPathComponent("stations/\(observation)/observations/latest"), resolvingAgainstBaseURL: false)
			
			return components!.url!
		}
	}
}
