//
//  SearchViewModel.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 12/9/21.
//  Copyright © 2021 Kate Duncan-Welke. All rights reserved.
//

import Foundation
import CoreData
import MapKit
import WidgetKit

public class SearchViewModel {

    private let viewModel = ViewModel()

    func hasConnection() -> Bool {
        return NetworkMonitor.connection
    }

    func centerMapLocation() -> MKCoordinateRegion {
        // center map on geographic center of us
        let coordinate = CLLocationCoordinate2D(latitude: 39.50, longitude: -98.35)
        let regionRadius: CLLocationDistance = 3500000
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)

        return region
    }

    func getResultItem(index: Int) -> CLPlacemark {
        return LocationSearch.searchResults[index].placemark
    }

    func getResultCount() -> Int {
        return LocationSearch.searchResults.count
    }

    func getLocationName(index: Int) -> String {
        return LocationSearch.searchResults[index].placemark.name ?? ""
    }

    func getAddress(index: Int) -> String {
        return LocationManager.parseAddress(selectedItem: LocationSearch.searchResults[index].placemark) 
    }

    func setLatLong(index: Int) {
        let selectedLocation = LocationSearch.searchResults[index].placemark

        LocationSearch.latitude = selectedLocation.coordinate.latitude
        LocationSearch.longitude = selectedLocation.coordinate.longitude
    }

    func addSelectedLocation() {
        // add page to page controller, refresh page count etc
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addPage"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "getNextPage"), object: nil)
        }
    }

    func getLocation(completionHandler: @escaping (Bool) -> Void) {
        DataManager<Location>.fetch() { [weak self] result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    guard let data = response.first else { return }
                    ForecastSearch.gridX = data.properties.gridX
                    ForecastSearch.gridY = data.properties.gridY
                    ForecastSearch.station = data.properties.cwa

                    if ForecastSearch.station != "" {
                        self?.getStation(completion: { reply in
                            if reply {
                                completionHandler(true)
                            }
                        })
                    }

                    NetworkMonitor.status = .normal
                }
            case .failure(let error):
                print("error")
                completionHandler(false)
            }
        }
    }

    func getStation(completion: @escaping (Bool) -> Void) {
        DataManager<Stations>.fetch() { result in
            switch result {
            case .success(let response):
                guard let data = response.first else { return }

                ForecastSearch.observationStation = data.features.first?.properties.stationIdentifier ?? ""

                completion(true)
            case .failure(let error):
                print("fail")
                completion(false)
            }
        }
    }

    func getRegion(coordinate: CLLocationCoordinate2D) -> MKCoordinateRegion {
        let regionRadius: CLLocationDistance = 10000
        return MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
    }

    func updateLocationFromMapTap(location: MKPlacemark, completion: @escaping (MKAnnotation?) -> Void) {
        LocationSearch.latitude = location.coordinate.latitude
        LocationSearch.longitude = location.coordinate.longitude

        let coordinate = CLLocationCoordinate2D(latitude: LocationSearch.latitude, longitude: LocationSearch.longitude)
        let annotation = MKPointAnnotation()

        // parse address to assign it to title for pin
        let locale = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        var title = "None"

        geocoder.reverseGeocodeLocation(locale, completionHandler: { (placemarks, error) in
            if error == nil {
                guard let firstLocation = placemarks?[0] else { return }
                title = LocationManager.parseAddress(selectedItem: firstLocation)
                annotation.title = title
                annotation.coordinate = coordinate
                completion(annotation)
            } else {
                // an error occurred during geocoding
                // if there had been a connection and it was suddenly lost, show error
                // otherwise this error message will be covered by networking error feedback
                completion(nil)
                if NetworkMonitor.connection {
                    //self?.showAlert(title: "Network Lost", message: "The location cannot be found - please check your network connection")
                }
            }
        })
    }

    func updateLocationFromSearch(location: CLPlacemark, completion: @escaping (MKAnnotation?) -> Void) {

        let coordinate = CLLocationCoordinate2D(latitude: LocationSearch.latitude, longitude: LocationSearch.longitude)
        let annotation = MKPointAnnotation()

        // parse address to assign it to title for pin
        let locale = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        var title = "None"

        geocoder.reverseGeocodeLocation(locale, completionHandler: { (placemarks, error) in
            if error == nil {
                guard let firstLocation = placemarks?[0] else { return }
                title = LocationManager.parseAddress(selectedItem: firstLocation)
                annotation.title = title
                annotation.coordinate = coordinate
                completion(annotation)
            } else {
                // an error occurred during geocoding
                // if there had been a connection and it was suddenly lost, show error
                // otherwise this error message will be covered by networking error feedback
                completion(nil)
                if NetworkMonitor.connection {
                    //self?.showAlert(title: "Network Lost", message: "The location cannot be found - please check your network connection")
                }
            }
        })
    }

    func clearSearch() {
        LocationSearch.latitude = 0
        LocationSearch.longitude = 0
        LocationSearch.searchResults.removeAll()
        ForecastSearch.gridX = 0
        ForecastSearch.gridY = 0
        ForecastSearch.station = ""
        ForecastSearch.observationStation = ""
    }

    func saveLocation(annotation: MKAnnotation) {
        var managedContext = CoreDataManager.shared.managedObjectContext

        let newLocation = Saved(context: managedContext)

        newLocation.latitude = LocationSearch.latitude
        newLocation.longitude = LocationSearch.longitude
        newLocation.name = annotation.title ?? ""
        newLocation.observation = ForecastSearch.observationStation
        newLocation.station = ForecastSearch.station
        newLocation.xCoord = Int16(ForecastSearch.gridX)
        newLocation.yCoord = Int16(ForecastSearch.gridY)

        if WeatherLocations.locations.isEmpty {
            if #available(iOS 14.0, *) {
                print("reload widget")
                WidgetCenter.shared.reloadAllTimelines()
            } else {
                // Fallback on earlier versions
            }
        }

        WeatherLocations.locations.append(newLocation)

        do {
            try managedContext.save()
            print("saved")
        } catch {
            // this should never be displayed but is here to cover the possibility
            //showAlert(title: "Save failed", message: "Notice: Data has not successfully been saved.")
        }
    }
}

