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

    func getCurrentPage() -> Int {
        return PageControllerManager.currentPage
    }

    func getWeatherLocationTotal() -> Int {
        print("total locations \(WeatherLocations.locations.count)")
        return WeatherLocations.locations.count
    }

    func loadLocations() {
        var managedContext = CoreDataManager.shared.managedObjectContext
        var fetchRequest = NSFetchRequest<Saved>(entityName: "Saved")

        do {
            WeatherLocations.locations = try managedContext.fetch(fetchRequest)
            print("locations loaded")
        } catch let error as NSError {
            //showAlert(title: "Could not retrieve data", message: "\(error.userInfo)")
        }
    }
}

