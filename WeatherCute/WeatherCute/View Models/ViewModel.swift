//
//  ViewModel.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 12/8/21.
//  Copyright © 2021 Kate Duncan-Welke. All rights reserved.
//

import Foundation
import CoreData

public class ViewModel {

    func setUpNetworkMonitor() {
        NetworkMonitor.monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("connection successful")
                NetworkMonitor.connection = true

                // if network available, check if status had been lost
                if NetworkMonitor.status == .lost {
                    // if so, refresh data
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "retrieveData"), object: nil)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "returned"), object: nil)
                    }
                }

                NetworkMonitor.status = .normal
            } else if path.status == .unsatisfied {
                print("no connection")
                NetworkMonitor.connection = false
                NetworkMonitor.status = .lost

                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fail"), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "networkWhoops"), object: nil)

                }
            }
        }

        let queue = DispatchQueue(label: "Monitor")
        NetworkMonitor.monitor.start(queue: queue)
    }

    func changeUnit(index: Int) {
        if index == 0 {
            Temp.currentUnit = .fahrenheit
        } else {
            Temp.currentUnit = .celsius
        }
    }

    func getSegment() -> Int {
        switch Temp.currentUnit {
        case .fahrenheit:
            return 0
        case .celsius:
            return 1
        }
    }

    func setSearchParameters(location: Saved) {
        LocationSearch.latitude = location.latitude
        LocationSearch.longitude = location.longitude

        ForecastSearch.gridX = Int(location.xCoord)
        ForecastSearch.gridY = Int(location.yCoord)
        ForecastSearch.station = location.station ?? ""
        ForecastSearch.observationStation = location.observation ?? ""
    }

    func getAll() {
        var index = 0

        for location in WeatherLocations.locations {
            setSearchParameters(location: location)
            getWeatherData(index: index)
            getForecastData(index: index)
            getAlerts(index: index)
            index += 1
        }

        // create page controller pages after data load
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addPage"), object: nil)
    }

    func getWeatherData(index: Int) {
        DataManager<Current>.fetch() { result in
            print("fetch")
            switch result {
            case .success(let response):
                if let data = response.first {
                    WeatherLocations.currentConditions[index] = data
                }

                print(response)

                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshContent"), object: nil)
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    func getForecastData(index: Int) {
        DataManager<Forecast>.fetch() { result in
            print("fetch")
            switch result {
            case .success(let response):
                if let data = response.first?.properties.periods {
                    var forecasts: [ForecastData] = []

                    for forecast in data {
                        forecasts.append(forecast)
                        print(forecast)
                    }

                    WeatherLocations.forecasts[index] = forecasts
                }
                
                print(response)
            case .failure(let error):
                print(error)
            }
        }
    }

    func getAlerts(index: Int) {
        DataManager<Alert>.fetch() { result in
            print("fetch")
            switch result {
            case .success(let response):
                if let data = response.first?.features {
                    var alertList: [AlertInfo] = []

                    for alert in data {
                        alertList.append(alert)
                        print(alert)
                    }

                    WeatherLocations.alerts[index] = alertList
                }

                print(response)
            case .failure(let error):
                print(error)
            }
        }
    }

    func getCurrentPage() -> Int {
        return PageControllerManager.currentPage
    }

    func getWeatherLocationTotal() -> Int {
        return WeatherLocations.locations.count
    }

    func loadLocations() {
        var managedContext = CoreDataManager.shared.managedObjectContext
        var fetchRequest = NSFetchRequest<Saved>(entityName: "Saved")

        do {
            WeatherLocations.locations = try managedContext.fetch(fetchRequest)
            print("locations loaded")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refresh"), object: nil)
        } catch let error as NSError {
            //showAlert(title: "Could not retrieve data", message: "\(error.userInfo)")
        }
    }
}

