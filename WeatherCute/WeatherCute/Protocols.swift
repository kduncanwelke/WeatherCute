//
//  Protocols.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 5/30/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation
import MapKit

// handle updating map location when locale is changed
protocol MapUpdaterDelegate: class {
	func updateMapLocation(for: MKPlacemark)
}

protocol CollectionViewTapDelegate: class {
	func longPress(sender: ForecastCollectionViewCell, state: UIGestureRecognizer.State) 
}
