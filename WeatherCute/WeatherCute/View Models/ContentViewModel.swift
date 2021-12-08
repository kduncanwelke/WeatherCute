//
//  ContentViewModel.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 12/8/21.
//  Copyright © 2021 Kate Duncan-Welke. All rights reserved.
//

import Foundation

public class ContentViewModel {

    func getLocationName() -> String {
        return WeatherLocations.locations[PageControllerManager.currentPage].name ?? ""
    }

    func getObservationName() -> String {
        return WeatherLocations.locations[PageControllerManager.currentPage].observation ?? ""
    }

    func getCurrentTemp() -> String {
        if let current = WeatherLocations.currentConditions[PageControllerManager.currentPage] {
            let temp = current.properties.temperature.value
            return " \(temp)°"
        } else {
            return "No data"
        }
    }

    func getCurrentDescription() -> String {
        if let current = WeatherLocations.currentConditions[PageControllerManager.currentPage] {
            return current.properties.textDescription
        } else {
            return "No data"
        }
    }

    func getCurrentHumidity() -> String {
        if let current = WeatherLocations.currentConditions[PageControllerManager.currentPage] {
            let humidity = current.properties.relativeHumidity.value
            return "\(humidity)%"
        } else {
            return "No data"
        }
    }

    func getCurrentDewpoint() -> String {
        if let current = WeatherLocations.currentConditions[PageControllerManager.currentPage] {
            let dew = current.properties.dewpoint.value
            return "\(dew)°"
        } else {
            return "No data"
        }
    }

    func getCurrentHeatChill() -> String {
        if let current = WeatherLocations.currentConditions[PageControllerManager.currentPage] {
            if let heat = current.properties.heatIndex.value {
                return "\(heat)°"
            } else if let chill = current.properties.windChill.value {
                return "\(chill)°"
            } else {
                return "N/A"
            }
        } else {
            return "No data"
        }
    }

    func setHeatChillLabel() -> String {
        if let current = WeatherLocations.currentConditions[PageControllerManager.currentPage] {
            if let heat = current.properties.heatIndex.value {
                return "Heat Index"
            } else if let chill = current.properties.windChill.value {
                return "Wind Chill"
            } else {
                return "Heat Index"
            }
        } else {
            return "Heat Index"
        }
    }
}
