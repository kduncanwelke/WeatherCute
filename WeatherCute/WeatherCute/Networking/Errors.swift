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
    case noNetwork
	
	var localizedDescription: String {
		switch self {
		case .networkError:
			return "The NWS API may be experiencing an interruption - please wait and try again."
        case .noNetwork:
            return "The network is currently unavailable, please check your wifi or data connection."
		case .otherError:
			return "An unexpected error has occurred. Please wait and try again."
		case .noDataError:
			return "Please check your selection; the National Weather Service cannot retrieve its data."
		}
	}
}
