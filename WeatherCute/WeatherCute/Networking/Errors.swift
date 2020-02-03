//
//  Errors.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 5/29/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation

// error to be used in the case of bad access to network
enum Errors: Error {
	case networkError
	case otherError
	case noDataError
	
	var localizedDescription: String {
		switch self {
		case .networkError:
			return "The network could not be reached - data may not be current or complete. Please try to refresh the view or check your connection."
		case .otherError:
			return "An unexpected error has occurred and not all data could be retrieved. The NWS API may not have current data available. Please wait and try again."
		case .noDataError:
			return "Please check your selection; the National Weather Service cannot retrieve its data."
		}
	}
}
