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
}

extension UIView {
	func goDown() {
		UIView.animate(withDuration: 0.2, animations: {
			self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
		}, completion: { [unowned self] _ in
			self.isHidden = true
			//self.transform = CGAffineTransform.identity
		})
	}
	
	func popUp() {
		UIView.animate(withDuration: 0.2, animations: {
			self.isHidden = false
			self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
			self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
		}, completion: { [unowned self] _ in
			self.transform = CGAffineTransform.identity
		})
	}
}
