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
    @IBOutlet weak var noNetworkLabel: UILabel!
    @IBOutlet weak var cancel: UIButton!

    
	// MARK: Variables

	var searchController = UISearchController(searchResultsController: nil)

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
        searchController.searchBar.tintColor = .darkGray
    
		navigationItem.searchController = searchController
		navigationItem.hidesSearchBarWhenScrolling = false
		definesPresentationContext = true

        if #available(iOS 13.0, *) {
            searchController.searchBar.tintColor = .darkGray
            searchController.searchBar.searchTextField.attributedPlaceholder =  NSAttributedString.init(string: "Type to find location . . .", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
            searchController.searchBar.tintColor = .darkGray

            if let clearButton = searchController.searchBar.searchTextField.value(forKey: "_clearButton") as? UIButton {
                   let templateImage = clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
                   clearButton.setImage(templateImage, for: .normal)
                   clearButton.tintColor = .darkGray
            }
        } else {
            // Fallback on earlier versions
        }
		
        NotificationCenter.default.addObserver(self, selector: #selector(networkBack), name: NSNotification.Name(rawValue: "networkBack"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(fail), name: NSNotification.Name(rawValue: "fail"), object: nil)
        
        loadingIndicator.stopAnimating()

        mapView.setRegion(searchViewModel.centerMapLocation(), animated: false)
    }
	
	// MARK: Custom functions

    @objc func networkBack() {
        noNetworkLabel.isHidden = true

        if locationLabel.text != "" {
            useThisLocationButton.isEnabled = true
            useThisLocationButton.alpha = 1.0
        }
    }
    
    @objc func fail() {
        print("fail called")
        DispatchQueue.main.async { [weak self] in
            self?.noNetworkLabel.isHidden = false
            self?.loadingIndicator.stopAnimating()
            
            // if network was lost, disable add button
            self?.useThisLocationButton.isEnabled = false
            self?.useThisLocationButton.alpha = 0.5
            self?.cancel.isEnabled = true
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
            // wipe annotations
            mapView.removeAnnotations(mapView.annotations)

			let tappedLocation = sender.location(in: mapView)
			let coordinate = mapView.convert(tappedLocation, toCoordinateFrom: mapView)
			let placemark = MKPlacemark(coordinate: coordinate)

            searchViewModel.updateLocationFromMapTap(location: placemark, completion: { [weak self] pin in
                if let newPin = pin {
                    self?.mapView.addAnnotation(newPin)
                    self?.locationLabel.text = newPin.title ?? "None"

                    if let region = self?.searchViewModel.getRegion(coordinate: newPin.coordinate) {
                        self?.mapView.setRegion(region, animated: true)
                    }

                    self?.useThisLocationButton.isEnabled = true
                    self?.useThisLocationButton.alpha = 1.0
                }
            })
		}
	}
	
	@IBAction func addLocationTapped(_ sender: UIButton) {
		if mapView.annotations.isEmpty {
			showAlert(title: "No location selected", message: "Please choose a location to add")
			return
		}
        
		if locationLabel.text != "" {
            if searchViewModel.hasConnection() {
                print("has connection")
                loadingIndicator.startAnimating()

                // disable button to prevent double tap
                useThisLocationButton.isEnabled = false
                useThisLocationButton.alpha = 0.5

                // disable cancel button while loading
                cancel.isEnabled = false

                searchViewModel.getLocation(completionHandler: { [weak self] success in
                    if success {
                        if let pin = self?.mapView.annotations.first {
                            self?.searchViewModel.saveLocation(annotation: pin)
                            self?.searchViewModel.addSelectedLocation()

                            DispatchQueue.main.async {
                                self?.loadingIndicator.stopAnimating()
                                self?.cancel.isEnabled = true
                                self?.searchViewModel.clearSearch()
                                self?.dismiss(animated: true, completion: nil)
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self?.loadingIndicator.stopAnimating()
                            self?.cancel.isEnabled = true
                            self?.searchViewModel.clearSearch()
                            self?.clearMap()
                            self?.showAlert(title: "Cannot add location", message: Errors.noDataError.localizedDescription)
                        }
                    }
                })
            } else {
                searchViewModel.clearSearch()
                clearMap()
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
        // wipe annotations
        mapView.removeAnnotations(mapView.annotations)

        searchViewModel.updateLocationFromSearch(location: searchViewModel.getResultItem(index: index), completion: { [weak self] pin in
            if let newPin = pin {
                self?.mapView.addAnnotation(newPin)
                self?.locationLabel.text = newPin.title ?? "None"

                if let region = self?.searchViewModel.getRegion(coordinate: newPin.coordinate) {
                    self?.mapView.setRegion(region, animated: true)
                }

                self?.useThisLocationButton.isEnabled = true
                self?.useThisLocationButton.alpha = 1.0
            }
        })
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
