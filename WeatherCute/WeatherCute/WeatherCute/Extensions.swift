//
//  Extensions.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 5/31/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation
import UIKit

// add reusable alert functionality
extension UIViewController {
	func showAlert(title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
	
	func alertsActive(title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
		alert.addAction(UIAlertAction(title: "View", style: .default, handler:  { action in self.performSegue(withIdentifier: "viewAlerts", sender: self) }))
		alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
}
