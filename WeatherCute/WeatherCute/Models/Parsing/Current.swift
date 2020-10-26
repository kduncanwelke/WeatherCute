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

struct CurrentCondition: Decodable {
	var textDescription: String
	var temperature: Temperature
	var dewpoint: DewPoint
	var windChill: WindChill
	var heatIndex: HeatIndex
	var relativeHumidity: Humidity
	var icon: String?
}

struct Temperature: Decodable {
	var value: Double?
	var unitCode: String
    
    init(value: Double?, unitCode: String) {
        if let temp = value {
            self.value = Double(temp)
        }
        self.unitCode = unitCode
    }
    
    enum CodingKeys: String, CodingKey {
        case value = "value", unitCode = "unitCode"
    }
}

struct DewPoint: Decodable {
	var value: Double?
	var unitCode: String
    
    init(value: Double?, unitCode: String) {
        if let dewpoint = value {
            self.value = Double(dewpoint)
        }
        self.unitCode = unitCode
    }
    
    enum CodingKeys: String, CodingKey {
        case value = "value", unitCode = "unitCode"
    }
}

struct WindChill: Decodable {
	var value: Double?
	var unitCode: String
    
    init(value: Double?, unitCode: String) {
        if let windchill = value {
            self.value = Double(windchill)
        }
        self.unitCode = unitCode
    }
    
    enum CodingKeys: String, CodingKey {
        case value = "value", unitCode = "unitCode"
    }
}

struct HeatIndex: Decodable {
	var value: Double?
	var unitCode: String
    
    init(value: Double?, unitCode: String) {
        if let heatindex = value {
            self.value = Double(heatindex)
        }
        self.unitCode = unitCode
    }
    
    enum CodingKeys: String, CodingKey {
        case value = "value", unitCode = "unitCode"
    }
}

struct Humidity: Decodable {
	var value: Double?
    
    init(value: Double?) {
        if let humidity = value {
            self.value = Double(humidity)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case value = "value"
    }
}
