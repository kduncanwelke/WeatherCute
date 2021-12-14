//
//  EditViewModel.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 12/8/21.
//  Copyright © 2021 Kate Duncan-Welke. All rights reserved.
//

import Foundation
import CoreData

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
    }

    func swap(source: Int, destination: Int) {
        var swapping = WeatherLocations.locations.remove(at: source)
        WeatherLocations.locations.insert(swapping, at: destination)

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

        resaveLocations()
    }

    func deleteLocation(index: Int) {
        var managedContext = CoreDataManager.shared.managedObjectContext

        managedContext.delete(WeatherLocations.locations[index])
        WeatherLocations.locations.remove(at: index)

        do {
            try managedContext.save()
            print("delete successful")
        } catch {
            print("Failed to save")
        }

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatePageControl"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "getPrevPage"), object: nil)
    }

    func resaveLocations() {
        var managedContext = CoreDataManager.shared.managedObjectContext

        let locationsList = WeatherLocations.locations

        do {
            try managedContext.save()
            print("resaved")
        } catch {
            // this should never be displayed but is here to cover the possibility
            //showAlert(title: "Save failed", message: "Notice: Data has not successfully been saved.")
        }

        // re-set up page controller
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addPage"), object: nil)
    }
}
