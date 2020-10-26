//
//  SearchType.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 5/29/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation

// protocol for search types, used for generics in data manager
protocol SearchType: Decodable {
	static var endpoint: Endpoint { get }
}
