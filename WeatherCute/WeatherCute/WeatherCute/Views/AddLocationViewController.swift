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
	
	// MARK: Variables
	
	var locationFromMapTap = false
	var searchController = UISearchController(searchResultsController: nil)
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		mapView.delegate = self
		
		// set up search bar
		let resultsTableController = SearchTableViewController()
		resultsTableController.mapView = mapView
		resultsTableController.delegate = self
		
		// set up search controller for map search
		searchController = UISearchController(searchResultsController: resultsTableController)
		searchController.searchResultsUpdater = resultsTableController
		searchController.searchBar.autocapitalizationType = .none
		
		searchController.searchBar.placeholder = "Type to a find location . . ."
		searchController.delegate = self
		searchController.searchBar.delegate = self // Monitor when the search button is tapped.
		
		navigationItem.searchController = searchController
		navigationItem.hidesSearchBarWhenScrolling = false
		definesPresentationContext = true
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
					
					self?.getStation()
				}
			case .failure(let error):
				print(error)
			}
		}
	}
	
	func getStation() {
		DataManager<Stations>.fetch() { result in
			switch result {
			case .success(let response):
				DispatchQueue.main.async {
					guard let data = response.first else { return }
				
					ForecastSearch.observationStation = data.features.first?.properties.stationIdentifier ?? "None"
				}
			case .failure(let error):
				print(error)
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
			
			geocoder.reverseGeocodeLocation(locale, completionHandler: { [unowned self] (placemarks, error) in
				if error == nil {
					guard let firstLocation = placemarks?[0] else { return }
					annotation.title = LocationManager.parseAddress(selectedItem: firstLocation)
					self.locationLabel.text = annotation.title
				}
				else {
					// an error occurred during geocoding
					self.showAlert(title: "Error geocoding", message: "Location could not be parsed")
				}
			})
		} else {
			// otherwise use location that was included with location object, which came from a search
			annotation.title = LocationManager.parseAddress(selectedItem: location)
		}
		
		annotation.coordinate = coordinate
		mapView.addAnnotation(annotation)
		mapView.setRegion(region, animated: true)
		
		locationLabel.text = annotation.title
		
		getLocation()
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
		
		guard let name = locationLabel.text else { return }
		
		let weather = SavedLocation(name: name, latitude: LocationSearch.latitude, longitude: LocationSearch.longitude, xCoord: ForecastSearch.gridX, yCoord: ForecastSearch.gridY, station: ForecastSearch.station, observationStation: ForecastSearch.observationStation)
		
		WeatherLocations.locations.append(weather)

		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refresh"), object: nil)
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateSectionCount"), object: nil)
		self.dismiss(animated: true, completion: nil)
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
