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

public class SearchViewModel {

    private let viewModel = ViewModel()

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
        // retrieve data from api
        viewModel.getWeatherData(index: WeatherLocations.locations.count-1)
        viewModel.getForecastData(index: WeatherLocations.locations.count-1)
        viewModel.getAlerts(index: WeatherLocations.locations.count-1)

        // add page to page controller, refresh page count etc
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addPage"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "getNextPage"), object: nil)
    }

    func getLocation(completionHandler: @escaping () -> Void) {
        DataManager<Location>.fetch() { [weak self] result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    guard let data = response.first else { return }
                    ForecastSearch.gridX = data.properties.gridX
                    ForecastSearch.gridY = data.properties.gridY
                    ForecastSearch.station = data.properties.cwa

                    if ForecastSearch.station != "" {
                        self?.getStation()
                    }

                    NetworkMonitor.status = .normal
                }
            case .failure(let error):
                print("error")
            }
        }
    }

    func getStation() {
        DataManager<Stations>.fetch() { result in
            switch result {
            case .success(let response):
                guard let data = response.first else { return }

                ForecastSearch.observationStation = data.features.first?.properties.stationIdentifier ?? ""

            case .failure(let error):
               print("fail")
            }
        }
    }

    func updateLocationFromMapTap(location: MKPlacemark) -> (annotation: MKAnnotation, region: MKCoordinateRegion) {
        LocationSearch.latitude = location.coordinate.latitude
        LocationSearch.longitude = location.coordinate.longitude

        let coordinate = CLLocationCoordinate2D(latitude: LocationSearch.latitude, longitude: LocationSearch.longitude)
        let regionRadius: CLLocationDistance = 10000
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        let annotation = MKPointAnnotation()

        // parse address to assign it to title for pin
        let locale = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()

        geocoder.reverseGeocodeLocation(locale, completionHandler: { [weak self] (placemarks, error) in
            if error == nil {
                guard let firstLocation = placemarks?[0] else { return }
                annotation.title = LocationManager.parseAddress(selectedItem: firstLocation)
            } else {
                // an error occurred during geocoding
                // if there had been a connection and it was suddenly lost, show error
                // otherwise this error message will be covered by networking error feedback
                if NetworkMonitor.connection {
                    //self?.showAlert(title: "Network Lost", message: "The location cannot be found - please check your network connection")
                }
            }
        })

        annotation.coordinate = coordinate

        return (annotation, region)
    }

    func updateLocationFromSearch(location: CLPlacemark) -> (annotation: MKAnnotation, region: MKCoordinateRegion) {

        let coordinate = CLLocationCoordinate2D(latitude: LocationSearch.latitude, longitude: LocationSearch.longitude)
        let regionRadius: CLLocationDistance = 10000
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        let annotation = MKPointAnnotation()

        // parse address to assign it to title for pin
        let locale = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()

        geocoder.reverseGeocodeLocation(locale, completionHandler: { [weak self] (placemarks, error) in
            if error == nil {
                guard let firstLocation = placemarks?[0] else { return }
                annotation.title = LocationManager.parseAddress(selectedItem: firstLocation)
            } else {
                // an error occurred during geocoding
                // if there had been a connection and it was suddenly lost, show error
                // otherwise this error message will be covered by networking error feedback
                if NetworkMonitor.connection {
                    //self?.showAlert(title: "Network Lost", message: "The location cannot be found - please check your network connection")
                }
            }
        })

        annotation.coordinate = coordinate

        return (annotation, region)
    }

    func clearSearch() {
        LocationSearch.latitude = 0
        LocationSearch.longitude = 0
        LocationSearch.searchResults.removeAll()
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

        WeatherLocations.locations.append(newLocation)

        do {
            try managedContext.save()
            print("saved")
        } catch {
            // this should never be displayed but is here to cover the possibility
            //showAlert(title: "Save failed", message: "Notice: Data has not successfully been saved.")
        }

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refresh"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "getNextPage"), object: nil)
    }
}

