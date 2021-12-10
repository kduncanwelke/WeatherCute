//
//  ObservationViewModel.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 12/10/21.
//  Copyright © 2021 Kate Duncan-Welke. All rights reserved.
//

import Foundation

public class ObservationViewModel {

    func removeResult() {
        WeatherLocations.stations.removeAll()
    }

    func getStations(completionHandler: @escaping () -> Void) {
        DataManager<Stations>.fetch() { result in
            switch result {
            case .success(let response):
                guard let data = response.first?.features else { return }

                for stationInfo in data {
                    WeatherLocations.stations.append(stationInfo.properties)
                }
            case .failure(let error):
                print("fail")
            }
        }
    }

    func getStationCount() -> Int {
        return WeatherLocations.stations.count
    }

    func getLabel(index: Int) -> String {
        return WeatherLocations.stations[index].stationIdentifier
    }

    func getName(index: Int) -> String {
        return WeatherLocations.stations[index].name
    }

    func resaveObservation(index: Int) {
        // save changed observation station into core data object
        var managedContext = CoreDataManager.shared.managedObjectContext

        let current = WeatherLocations.locations[PageControllerManager.currentPage]

        current.observation = WeatherLocations.stations[index].stationIdentifier

        do {
            try managedContext.save()
            print("resave successful")
        } catch {
            // this should never be displayed but is here to cover the possibility
            //showAlert(title: "Save failed", message: "Notice: Data has not successfully been saved.")
        }
    }
}
