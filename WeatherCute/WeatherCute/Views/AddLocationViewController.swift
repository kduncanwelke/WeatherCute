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
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
	// MARK: Variables
	
	var locationFromMapTap = false
	var searchController = UISearchController(searchResultsController: nil)
    var networkMessageShown = false
	
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
		
        NotificationCenter.default.addObserver(self, selector: #selector(networkBack), name: NSNotification.Name(rawValue: "networkBack"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(networkGone), name: NSNotification.Name(rawValue: "networkGone"), object: nil)
        
        loadingIndicator.stopAnimating()
        
		// center map on geographic center of us
		let coordinate = CLLocationCoordinate2D(latitude: 39.50, longitude: -98.35)
		let regionRadius: CLLocationDistance = 3500000
		let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
		
		mapView.setRegion(region, animated: false)
		
    }
	
	// MARK: Custom functions
    
    @objc func networkBack() {
        print("network restored")
        // use delay to give connection time to establish successfully
        networkMessageShown = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            if let coordinate = self?.mapView.annotations.first?.coordinate {
                let placemark = MKPlacemark(coordinate: coordinate)
                LocationSearch.latitude = placemark.coordinate.latitude
                LocationSearch.longitude = placemark.coordinate.longitude
                self?.updateLocation(location: placemark)
            }
        }
    }
    
    @objc func networkGone() {
        DispatchQueue.main.async {
            self.loadingIndicator.stopAnimating()
            
            // if data was not retrieved in time, disable add button
            if ForecastSearch.gridX == 0 || ForecastSearch.gridY == 0 || ForecastSearch.station == "" || ForecastSearch.observationStation == "" {
                self.useThisLocationButton.isEnabled = false
                self.useThisLocationButton.alpha = 0.5
            }
        }
    }
    
    func networkMessage() {
        print("show network message")
            if networkMessageShown == false {
            switch NetworkMonitor.status {
            case .normal:
                print("No problems")
            case .lost:
                // the network was lost
                // only show alerts on currently visible content view to prevent confusion
                showAlert(title: "No Network", message: Errors.noNetwork.localizedDescription)
                networkMessageShown = true
                print("network lost")
            case .other:
                if NetworkMonitor.connection == false {
                    // only show alerts on currently visible content view to prevent confusion
                    showAlert(title: "No Network", message: Errors.noNetwork.localizedDescription)
                    networkMessageShown = true
                    print("other no connection")
                } else {
                    showAlert(title: "Network Error", message: Errors.networkError.localizedDescription)
                    networkMessageShown = true
                    print("other")
                }
            }
        }
    }
	
	func getLocation() {
        DispatchQueue.main.async {
            self.loadingIndicator.startAnimating()
        }
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
                DispatchQueue.main.async {
                    self?.loadingIndicator.stopAnimating()
                    
                    switch error {
                    case Errors.noDataError:
                        self?.showAlert(title: "Invalid Selection", message: Errors.noDataError.localizedDescription)
                        // invalid selection is usually out of the country, not indicative of a network error
                        NetworkMonitor.status = .normal
                        self?.clearMap()
                    case Errors.noNetwork:
                        NetworkMonitor.status = .lost
                        self?.clearMap()
                    case Errors.networkError:
                        NetworkMonitor.status = .other
                    default:
                        NetworkMonitor.status = .other
                    }
                    
                    self?.networkMessage()
                }
            }
        }
	}
	
	func clearMap() {
		mapView.removeAnnotations(mapView.annotations)
		
		locationLabel.text = ""
		
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
                    
                    NetworkMonitor.status = .normal
                    self?.loadingIndicator.stopAnimating()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.loadingIndicator.stopAnimating()
                    self?.useThisLocationButton.isEnabled = false
                    self?.useThisLocationButton.alpha = 0.5
                    
                    switch error {
                    case Errors.networkError:
                        NetworkMonitor.status = .other
                    case Errors.noNetwork:
                        NetworkMonitor.status = .lost
                    default:
                        NetworkMonitor.status = .other
                    }
                    
                    self?.networkMessage()
                }
            }
        }
	}
	
	func updateLocation(location: MKPlacemark) {
        // if there's no network, exit early
        if NetworkMonitor.connection == false {
            networkMessage()
            return
        }
        
        // wipe annotations if location was updated
        mapView.removeAnnotations(mapView.annotations)
        
        getLocation()
        
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
				} else {
					// an error occurred during geocoding
                    // if there had been a connection and it was suddenly lost, show error
                    // otherwise this error message will be covered by networking error feedback
                    if NetworkMonitor.connection {
                        self?.showAlert(title: "Network Lost", message: "The location cannot be found - please check your network connection")
                    }
				}
			})
		} else {
			// otherwise use location that was included with location object, which came from a search
			annotation.title = LocationManager.parseAddress(selectedItem: location)
		}
			
		annotation.coordinate = coordinate
        locationLabel.text = annotation.title
		mapView.addAnnotation(annotation)
        useThisLocationButton.isEnabled = false
        useThisLocationButton.alpha = 0.5
        
		mapView.setRegion(region, animated: true)
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
        
		if locationLabel.text != "", let name = locationLabel.text {
            let weather = SavedLocation(name: name, latitude: LocationSearch.latitude, longitude: LocationSearch.longitude, xCoord: ForecastSearch.gridX, yCoord: ForecastSearch.gridY, station: ForecastSearch.station, observationStation: ForecastSearch.observationStation)
        
            if NetworkMonitor.connection {
                saveEntry(location: weather)
            } else {
                mapView.removeAnnotations(mapView.annotations)
                locationLabel.text = ""
                showAlert(title: "Cannot add location", message: "No network connection is available. Complete data for this location could not be retrieved.")
            }
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
