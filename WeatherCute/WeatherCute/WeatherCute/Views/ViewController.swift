//
//  ViewController.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 5/29/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController {
	
	// MARK: IBOutlets
	
	@IBOutlet weak var pageControl: UIPageControl!
	@IBOutlet weak var noDataLabel: UILabel!
	
	// MARK: Variables
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view
		
		updateSectionCount()
		
		NotificationCenter.default.addObserver(self, selector: #selector(sectionChanged), name: NSNotification.Name(rawValue: "sectionChanged"), object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(updateSectionCount), name: NSNotification.Name(rawValue: "updateSectionCount"), object: nil)
	}
	
	// MARK: Custom functions
	
	@objc func updateSectionCount() {
		if WeatherLocations.locations.isEmpty {
			noDataLabel.isHidden = false
		} else {
			noDataLabel.isHidden = true
		}
		
		pageControl.numberOfPages = WeatherLocations.locations.count
	}
	
	@objc func sectionChanged() {
		pageControl.currentPage = PageControllerManager.currentPage
	}

	@IBAction func addPressed(_ sender: UIButton) {
		performSegue(withIdentifier: "addLocation", sender: Any?.self)
	}
	
}
