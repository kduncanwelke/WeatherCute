//
//  LocationManager.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 5/30/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation
import CoreLocation

// handle address parsing, used in map view for earth satellite imagery
struct LocationManager {
	static func parseAddress(selectedItem: CLPlacemark) -> String {
		// put a space between "4" and "Melrose Place"
		let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
		// put a comma between street and city/state
		let comma = (selectedItem.locality != nil || selectedItem.administrativeArea != nil) && (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
		// put a space between "Washington" and "DC"
		let secondSpace = (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
		let addressLine = String(
			format:"%@%@%@",//%@%@%@%@%@",
			// street number
			//selectedItem.subThoroughfare ?? "",
			//firstSpace,
			// street name
			//selectedItem.thoroughfare ?? "",
			//comma,
			// city
			selectedItem.locality ?? "",
			secondSpace,
			// state
			selectedItem.administrativeArea ?? ""
		)
		
		return addressLine
	}
}
