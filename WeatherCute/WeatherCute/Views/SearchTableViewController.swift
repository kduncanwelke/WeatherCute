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

    // MARK: Variables

	var mapView: MKMapView? = nil
    private let searchViewModel = SearchViewModel()
	
	// delegate to pass search back to view controller
	weak var delegate: MapUpdaterDelegate?
	
	override func viewDidLoad() {
		self.tableView.delegate = self
		self.tableView.dataSource = self
        
		// set up table view qualities
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "searchCell")
        tableView.backgroundColor = UIColor(named: "Custom Background Color")
		tableView.rowHeight = 70.0
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchViewModel.getResultCount()
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
		var cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
		cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "searchCell")
		
		cell.backgroundColor = UIColor(named: "Custom Background Color")

        cell.textLabel?.text = searchViewModel.getLocationName(index: indexPath.row)
		cell.textLabel?.font = UIFont.systemFont(ofSize: 20.0)
        cell.textLabel?.textColor = UIColor(named: "Custom Text Color")
		
		// parse address to show in cell
		cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 15.0)
		cell.detailTextLabel?.textColor = UIColor(named: "Custom Text Color")
        cell.detailTextLabel?.text = searchViewModel.getAddress(index: indexPath.row)
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchViewModel.setLatLong(index: indexPath.row)

		// update location on map when back in earth view controller
        delegate?.updateMapLocation(index: indexPath.row)
		
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
			
            LocationSearch.searchResults = response.mapItems
			self?.tableView.reloadData()
		}
	}
}
