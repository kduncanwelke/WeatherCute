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

	var searchController = UISearchController(searchResultsController: nil)
    var networkMessageShown = false

    private let searchViewModel = SearchViewModel()
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		useThisLocationButton.layer.cornerRadius = 15
        useThisLocationButton.isEnabled = false
        useThisLocationButton.alpha = 0.5

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

        mapView.setRegion(searchViewModel.centerMapLocation(), animated: false)
    }
	
	// MARK: Custom functions
    
    @objc func networkBack() {
        print("network restored")
        networkMessageShown = false
    }
    
    @objc func networkGone() {
        DispatchQueue.main.async {
            self.loadingIndicator.stopAnimating()
            
            // if data was not retrieved in time, disable add button

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
	
	func clearMap() {
		mapView.removeAnnotations(mapView.annotations)
		locationLabel.text = ""
        mapView.setRegion(searchViewModel.centerMapLocation(), animated: false)
        useThisLocationButton.isEnabled = false
        useThisLocationButton.alpha = 0.5
	}

	// MARK: IBActions
	
	@IBAction func mapTapped(_ sender: UITapGestureRecognizer) {
		if sender.state == .ended {
			let tappedLocation = sender.location(in: mapView)
			let coordinate = mapView.convert(tappedLocation, toCoordinateFrom: mapView)
			let placemark = MKPlacemark(coordinate: coordinate)

            // if there's no network, exit early
            if NetworkMonitor.connection == false {
                networkMessage()
                return
            }

            // wipe annotations if location was updated
            mapView.removeAnnotations(mapView.annotations)
            let result = searchViewModel.updateLocationFromMapTap(location: placemark)
            mapView.addAnnotation(result.annotation)
            locationLabel.text = result.annotation.title ?? ""
            mapView.setRegion(result.region, animated: true)

            useThisLocationButton.isEnabled = true
            useThisLocationButton.alpha = 1.0
		}
	}
	
	
	@IBAction func addLocationTapped(_ sender: UIButton) {
		if mapView.annotations.isEmpty {
			showAlert(title: "No location selected", message: "Please choose a location to add")
			return
		}
        
		if locationLabel.text != "" {
            if NetworkMonitor.connection {
                searchViewModel.getLocation()
                if let pin = mapView.annotations.first {
                    searchViewModel.saveLocation(annotation: pin)
                    searchViewModel.addSelectedLocation()
                }
            } else {
                mapView.removeAnnotations(mapView.annotations)
                locationLabel.text = ""
                useThisLocationButton.isEnabled = false
                useThisLocationButton.alpha = 0.5
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
    func updateMapLocation(index: Int) {
        // set annotation from search
        let annotation = MKPointAnnotation()
        annotation.title = LocationManager.parseAddress(selectedItem: searchViewModel.getResultItem(index: index))
        useThisLocationButton.isEnabled = true
        useThisLocationButton.alpha = 1.0
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
