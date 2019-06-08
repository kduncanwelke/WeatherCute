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
	
	var localizedDescription: String {
		switch self {
		case .networkError:
			return "The network could not be reached successfully - please check your data or wifi connection."
		case .otherError:
			return "An unexpected error has occurred, please wait and try again."
		}
	}
}
