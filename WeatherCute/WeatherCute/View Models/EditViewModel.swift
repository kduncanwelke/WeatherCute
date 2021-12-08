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
        WeatherLocations.locations.remove(at: index)

        deleteLocation(index: index)

        // locations changed, re-fetch data to match up with new order
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "retrieveData"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "getPrevPage"), object: nil)
    }

    func swap(source: Int, destination: Int) {
        var swapping = WeatherLocations.locations.remove(at: source)
        WeatherLocations.locations.insert(swapping, at: destination)

        resaveLocations()

        // order was changed, re-fetch data to match up with new order
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "retrieveData"), object: nil)
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
    }

    func resaveLocations() {
        var managedContext = CoreDataManager.shared.managedObjectContext

        let locationsList = WeatherLocations.locations

        var i = 0
        print("resave")

        for location in locationsList {
            // reassign names to correct order after swap
            print(i)
            location.name = WeatherLocations.locations[i].name

            i += 1
        }

        do {
            try managedContext.save()
            print("resaved")
        } catch {
            // this should never be displayed but is here to cover the possibility
            //showAlert(title: "Save failed", message: "Notice: Data has not successfully been saved.")
        }
    }
}
