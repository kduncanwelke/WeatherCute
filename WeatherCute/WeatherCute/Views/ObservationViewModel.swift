//
//  ObservationViewModel.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 12/10/21.
//  Copyright © 2021 Kate Duncan-Welke. All rights reserved.
//

import Foundation

public class ObservationViewModel {

    func getStations(completionHandler: @escaping () -> Void) {
        DataManager<Stations>.fetch() { result in
            switch result {
            case .success(let response):
                guard let data = response.first?.features else { return }
                //print(data)
                print(PageControllerManager.currentPage)

                var result: [Identifier] = []
                
                for stationInfo in data {
                    result.append(stationInfo.properties)
                }
                
                WeatherLocations.stations[PageControllerManager.currentPage] = result

                completionHandler()
            case .failure(let error):
                print("fail")
                completionHandler()
            }
        }
    }

    func getStationCount() -> Int {
        if let stationCount = WeatherLocations.stations[PageControllerManager.currentPage]?.count {
            return stationCount
        } else {
            return 0
        }
    }

    func getLabel(index: Int) -> String {
        if let identifierName = WeatherLocations.stations[PageControllerManager.currentPage]?[index].stationIdentifier {
            return identifierName
        } else {
            return "Unknown"
        }
    }

    func getName(index: Int) -> String {
        if let stationName =  WeatherLocations.stations[PageControllerManager.currentPage]?[index].name {
            return stationName
        } else {
            return "Unknown"
        }
    }

    func resaveObservation(index: Int) {
        // save changed observation station into core data object
        var managedContext = CoreDataManager.shared.managedObjectContext

        let current = WeatherLocations.locations[PageControllerManager.currentPage]

        if let stationIdentifier = WeatherLocations.stations[PageControllerManager.currentPage]?[index].stationIdentifier {
            current.observation = stationIdentifier
        } else {
            return
        }

        do {
            try managedContext.save()
            print("resave successful")
        } catch {
            // this should never be displayed but is here to cover the possibility
            //showAlert(title: "Save failed", message: "Notice: Data has not successfully been saved.")
        }
    }
}
