//
//  AddLocationViewController.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 5/30/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class AddLocationViewController: UIViewController, UITableViewDelegate {

	// MARK: IBOutlets
	
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var locationLabel: UILabel!
	@IBOutlet weak var useThisLocationButton: UIButton!
	
	// MARK: Variables
	
	var locationFromMapTap = false
	var searchController = UISearchController(searchResultsController: nil)
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		useThisLocationButton.layer.cornerRadius = 15
        useThisLocationButton.isEnabled = false
        useThisLocationButton.alpha = 0.5
		
		ForecastSearch.gridX = 0
		ForecastSearch.gridY = 0
		ForecastSearch.station = ""
		ForecastSearch.observationStation = ""
		
		mapView.delegate = self
		
		// set up search bar
		let resultsTableController = SearchTableViewController()
		resultsTableController.mapView = mapView
		resultsTableController.delegate = self
		
		// set up search controller for map search
		searchController = UISearchController(searchResultsController: resultsTableController)
		searchController.searchResultsUpdater = resultsTableController
		searchController.searchBar.autocapitalizationType = .none
		
		searchController.searchBar.placeholder = "Type to find location . . ."
		searchController.delegate = self
		searchController.searchBar.delegate = self // Monitor when the search button is tapped.
        searchController.hidesNavigationBarDuringPresentation = false
		
		navigationItem.searchController = searchController
		navigationItem.hidesSearchBarWhenScrolling = false
		definesPresentationContext = true
		
		// center map on geographic center of us
		let coordinate = CLLocationCoordinate2D(latitude: 39.50, longitude: -98.35)
		let regionRadius: CLLocationDistance = 3500000
		let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
		
		mapView.setRegion(region, animated: false)
		
    }
	
	// MARK: Custom functions
	
	func getLocation() {
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
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    switch error {
                    case Errors.noDataError:
                        self?.showAlert(title: "Invalid Selection", message: Errors.noDataError.localizedDescription)
                        self?.clearMap()
                    case Errors.noNetwork:
                        self?.showAlert(title: "No Network", message: Errors.noNetwork.localizedDescription)
                        self?.clearMap()
                    case Errors.networkError:
                        self?.showAlert(title: "Network Error", message: Errors.networkError.localizedDescription)
                    default:
                        self?.showAlert(title: "Unknown Error", message: Errors.otherError.localizedDescription)
                    }
                }
            }
        }
	}
	
	func clearMap() {
		mapView.removeAnnotations(mapView.annotations)
		
		locationLabel.text = "No Selection"
		
		// center map on geographic center of us
		let coordinate = CLLocationCoordinate2D(latitude: 39.50, longitude: -98.35)
		let regionRadius: CLLocationDistance = 3500000
		let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
		
		mapView.setRegion(region, animated: false)
	}
	
	func getStation() {
        DataManager<Stations>.fetch() { [weak self] result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    guard let data = response.first else { return }
                
                    ForecastSearch.observationStation = data.features.first?.properties.stationIdentifier ?? ""
                    
                    if ForecastSearch.observationStation != "" {
                        self?.useThisLocationButton.isEnabled = true
                        self?.useThisLocationButton.alpha = 1.0
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.useThisLocationButton.isEnabled = false
                    self?.useThisLocationButton.alpha = 0.5
                    
                    switch error {
                    case Errors.networkError:
                        self?.showAlert(title: "Network Error", message: Errors.networkError.localizedDescription)
                    case Errors.noNetwork:
                        self?.showAlert(title: "No Network", message: Errors.noNetwork.localizedDescription)
                    default:
                        self?.showAlert(title: "Unknown Error", message: Errors.otherError.localizedDescription)
                    }
                }
            }
        }
	}
	
	func updateLocation(location: MKPlacemark) {
		// wipe annotations if location was updated
		mapView.removeAnnotations(mapView.annotations)
		
		let coordinate = CLLocationCoordinate2D(latitude: LocationSearch.latitude, longitude: LocationSearch.longitude)
		
		let regionRadius: CLLocationDistance = 10000
		
		let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
		
		let annotation = MKPointAnnotation()
		
		// if location came from map tap, parse address to assign it to title for pin
		if self.locationFromMapTap {
			let locale = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
			let geocoder = CLGeocoder()
			
			geocoder.reverseGeocodeLocation(locale, completionHandler: { [weak self] (placemarks, error) in
				if error == nil {
					guard let firstLocation = placemarks?[0] else { return }
					annotation.title = LocationManager.parseAddress(selectedItem: firstLocation)
					self?.locationLabel.text = annotation.title
				}
				else {
					// an error occurred during geocoding
					self?.showAlert(title: "Network Lost", message: "The location cannot be found - please check your network connection")
				}
			})
		} else {
			// otherwise use location that was included with location object, which came from a search
			annotation.title = LocationManager.parseAddress(selectedItem: location)
		}
		
		getLocation()
			
		annotation.coordinate = coordinate
		mapView.addAnnotation(annotation)
		mapView.setRegion(region, animated: true)
		
		locationLabel.text = annotation.title
	
	}
	
	func saveEntry(location: SavedLocation) {
		var managedContext = CoreDataManager.shared.managedObjectContext
		
		let newLocation = Saved(context: managedContext)
		
		newLocation.latitude = location.latitude
		newLocation.longitude = location.longitude
		newLocation.name = location.name
		newLocation.observation = location.observationStation
		newLocation.station = location.station
		
		if let x = location.xCoord, let y = location.yCoord {
			newLocation.xCoord = Int16(x)
			newLocation.yCoord = Int16(y)
		}
		
		WeatherLocations.locations.append(newLocation)
		
		do {
			try managedContext.save()
			print("saved")
		} catch {
			// this should never be displayed but is here to cover the possibility
			showAlert(title: "Save failed", message: "Notice: Data has not successfully been saved.")
		}
		
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refresh"), object: nil)
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "getNextPage"), object: nil)
		self.dismiss(animated: true, completion: nil)
	}
	
	// MARK: IBActions
	
	@IBAction func mapTapped(_ sender: UITapGestureRecognizer) {
		if sender.state == .ended {
			let tappedLocation = sender.location(in: mapView)
			let coordinate = mapView.convert(tappedLocation, toCoordinateFrom: mapView)
			let placemark = MKPlacemark(coordinate: coordinate)
			LocationSearch.latitude = placemark.coordinate.latitude
			LocationSearch.longitude = placemark.coordinate.longitude
			locationFromMapTap = true
			updateLocation(location: placemark)
		}
	}
	
	
	@IBAction func addLocationTapped(_ sender: UIButton) {
		if mapView.annotations.isEmpty {
			showAlert(title: "No location selected", message: "Please choose a location to add")
			return
		}
        
        if LocationSearch.latitude == 0 || LocationSearch.longitude == 0 {
            
        }
		
		guard let name = locationLabel.text else { return }
		
		let weather = SavedLocation(name: name, latitude: LocationSearch.latitude, longitude: LocationSearch.longitude, xCoord: ForecastSearch.gridX, yCoord: ForecastSearch.gridY, station: ForecastSearch.station, observationStation: ForecastSearch.observationStation)
	
        if NetworkMonitor.connection {
			saveEntry(location: weather)
		} else {
			mapView.removeAnnotations(mapView.annotations)
			locationLabel.text = ""
			showAlert(title: "Cannot add location", message: "No network connection is available. Complete data for this location could not be retrieved.")
		}
	}
	
	@IBAction func cancelTapped(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}
	
}

extension AddLocationViewController: MapUpdaterDelegate {
	// delegate used to pass location from search
	func updateMapLocation(for location: MKPlacemark) {
		updateLocation(location: location)
	}
}

extension AddLocationViewController: MKMapViewDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
	}
}

extension AddLocationViewController: UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
	// function needed to satisfy compiler
	func updateSearchResults(for searchController: UISearchController) {
	}
}
