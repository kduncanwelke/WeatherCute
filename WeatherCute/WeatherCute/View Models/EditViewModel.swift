//
//  EditViewModel.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 12/8/21.
//  Copyright © 2021 Kate Duncan-Welke. All rights reserved.
//

import Foundation
import CoreData
import WidgetKit

public class EditViewModel {

    func getTotalLocations() -> Int {
        return WeatherLocations.locations.count
    }

    func getPlaceName(index: Int) -> String {
        return WeatherLocations.locations[index].name ?? ""
    }

    func removeLocation(index: Int) {
        // reorder dictionaries
        if index == WeatherLocations.locations.count - 1 {
            // do nothing, this is the last item so nothing has to be shifted
        } else {
            for (page, data) in WeatherLocations.currentConditions {
                if page > index {
                    var newIndex = page - 1
                    WeatherLocations.currentConditions[newIndex] = data
                }
            }

            for (page, data) in WeatherLocations.forecasts {
                if page > index {
                    var newIndex = page - 1
                    WeatherLocations.forecasts[newIndex] = data
                }
            }

            for (page, data) in WeatherLocations.alerts {
                if page > index {
                    var newIndex = page - 1
                    WeatherLocations.alerts[newIndex] = data
                }
            }
        }

        deleteLocation(index: index)

        // reload widget if first location is changed, as widget uses first
        if index == 0 {
            if #available(iOS 14.0, *) {
                WidgetCenter.shared.reloadAllTimelines()
            } else {
                // Fallback on earlier versions
            }
        }
    }

    func swap(source: Int, destination: Int) {
        // swap dictionary data to the correct order
        let firstCondition = WeatherLocations.currentConditions[source]
        let secondCondition = WeatherLocations.currentConditions[destination]
        WeatherLocations.currentConditions[destination] = firstCondition
        WeatherLocations.currentConditions[source] = secondCondition

        let firstForecast = WeatherLocations.forecasts[source]
        let secondForecast = WeatherLocations.forecasts[destination]
        WeatherLocations.forecasts[destination] = firstForecast
        WeatherLocations.forecasts[source] = secondForecast

        let firstAlert = WeatherLocations.alerts[source]
        let secondAlert = WeatherLocations.alerts[destination]
        WeatherLocations.alerts[destination] = firstAlert
        WeatherLocations.alerts[source] = secondAlert

        resaveLocations(source: source, destination: destination)
    }

    func deleteLocation(index: Int) {
        var managedContext = CoreDataManager.shared.managedObjectContext

        managedContext.delete(WeatherLocations.locations[index])

        do {
            try managedContext.save()
            print("delete successful")
        } catch {
            print("Failed to save")
        }

        WeatherLocations.locations.remove(at: index)
        WeatherLocations.alerts.removeValue(forKey: index)
        WeatherLocations.currentConditions.removeValue(forKey: index)
        WeatherLocations.forecasts.removeValue(forKey: index)

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "getPrevPage"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatePageControl"), object: nil)
    }

    func resaveLocations(source: Int, destination: Int) {
        var managedContext = CoreDataManager.shared.managedObjectContext

        let locationsList = WeatherLocations.locations

        var first = WeatherLocations.locations[source]
        var second = WeatherLocations.locations[destination]

        // swap values here to ensure they are saved
        let latitude1 = first.latitude
        let longitude1 = first.longitude
        let observation1 = first.observation
        let station1 = first.station
        let xCoord1 = first.xCoord
        let yCoord1 = first.yCoord
        let name1 = first.name

        let latitude2 = second.latitude
        let longitude2 = second.longitude
        let observation2 = second.observation
        let station2 = second.station
        let xCoord2 = second.xCoord
        let yCoord2 = second.yCoord
        let name2 = second.name

        second.latitude = latitude1
        second.longitude = longitude1
        second.observation = observation1
        second.station = station1
        second.xCoord = xCoord1
        second.yCoord = yCoord1
        second.name = name1

        first.latitude = latitude2
        first.longitude = longitude2
        first.observation = observation2
        first.station = station2
        first.xCoord = xCoord2
        first.yCoord = yCoord2
        first.name = name2

        do {
            try managedContext.save()
            print("resaved")
        } catch {
            // this should never be displayed but is here to cover the possibility
            //showAlert(title: "Save failed", message: "Notice: Data has not successfully been saved.")
            print("not saved")
        }

        // re-set up page controller
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshContent"), object: nil)

        // reload widget if the first location was changed, as widget uses first
        if source == 0 || destination == 0 {
            if #available(iOS 14.0, *) {
                print("reload widget")
                WidgetCenter.shared.reloadAllTimelines()
            } else {
                // Fallback on earlier versions
            }
        }
    }
}
