//
//  SearchTableViewController.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 5/30/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class SearchTableViewController: UITableViewController {
	
	var resultsList: [MKMapItem] = [MKMapItem]()
	var mapView: MKMapView? = nil
	
	// delegate to pass search back to view controller
	weak var delegate: MapUpdaterDelegate?
	
	override func viewDidLoad() {
		self.tableView.delegate = self
		self.tableView.dataSource = self
        
		// set up table view qualities
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "searchCell")
		tableView.backgroundColor = UIColor(red:0.14, green:0.64, blue:1.00, alpha:1.0)
		tableView.rowHeight = 70.0
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return resultsList.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
		var cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
		cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "searchCell")
		
		cell.backgroundColor = UIColor(red:0.14, green:0.64, blue:1.00, alpha:1.0)
		
		// get map placemark and details
		let selectedItem = resultsList[indexPath.row].placemark
		cell.textLabel?.text = selectedItem.name
		cell.textLabel?.font = UIFont.systemFont(ofSize: 20.0)
		cell.textLabel?.textColor = UIColor.white
		
		// parse address to show in cell
		cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 15.0)
		cell.detailTextLabel?.textColor = UIColor.white
		cell.detailTextLabel?.text = LocationManager.parseAddress(selectedItem: selectedItem)
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let selectedLocation = resultsList[indexPath.row].placemark
		
		// pass coordinates into search object
		LocationSearch.latitude = selectedLocation.coordinate.latitude
		LocationSearch.longitude = selectedLocation.coordinate.longitude
		
		// update location on map when back in earth view controller
		delegate?.updateMapLocation(for: selectedLocation)
		
		self.dismiss(animated: true, completion: nil)
	}
}

// update results for search table
extension SearchTableViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		guard let mapView = mapView,
			let searchBarText = searchController.searchBar.text else { return }
		
		let request = MKLocalSearch.Request()
		request.naturalLanguageQuery = searchBarText
		request.region = mapView.region
		let search = MKLocalSearch(request: request)
		
		search.start { [weak self] response, _ in
			guard let response = response else {
				return
			}
			
			self?.resultsList = response.mapItems
			self?.tableView.reloadData()
		}
	}
	
}
