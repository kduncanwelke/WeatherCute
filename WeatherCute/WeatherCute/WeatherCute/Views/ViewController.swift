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
import CoreData

class ViewController: UIViewController {
	
	// MARK: IBOutlets
	
	@IBOutlet weak var pageControl: UIPageControl!
	@IBOutlet weak var noDataLabel: UILabel!
	@IBOutlet weak var container: UIView!
	@IBOutlet weak var deleteButton: UIButton!
	
	
	// MARK: Variables
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view
		
		loadSavedLocations()
		updateSectionCount()
		
		NotificationCenter.default.addObserver(self, selector: #selector(sectionChanged), name: NSNotification.Name(rawValue: "sectionChanged"), object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(updateSectionCount), name: NSNotification.Name(rawValue: "updateSectionCount"), object: nil)
	}
	
	// MARK: Custom functions
	
	func loadSavedLocations() {
		var managedContext = CoreDataManager.shared.managedObjectContext
		var fetchRequest = NSFetchRequest<Saved>(entityName: "Saved")
		
		do {
			WeatherLocations.locations = try managedContext.fetch(fetchRequest)
			print("locations loaded")
			NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refresh"), object: nil)
		} catch let error as NSError {
			showAlert(title: "Could not retrieve data", message: "\(error.userInfo)")
		}
	}
	
	@objc func updateSectionCount() {
		if WeatherLocations.locations.isEmpty {
			noDataLabel.isHidden = false
			deleteButton.isHidden = true
			container.isHidden = true
		} else {
			noDataLabel.isHidden = true
			deleteButton.isHidden = false
			container.isHidden = false
		}
		
		pageControl.numberOfPages = WeatherLocations.locations.count
	}
	
	@objc func sectionChanged() {
		pageControl.currentPage = PageControllerManager.currentPage
		print("section changed")
		print(PageControllerManager.currentPage)
	}

	@IBAction func addPressed(_ sender: UIButton) {
		performSegue(withIdentifier: "addLocation", sender: Any?.self)
	}
	
	@IBAction func removePressed(_ sender: UIButton) {
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "getPrevPage"), object: nil)
	}
	
	@IBAction func degreeSegmentChanged(_ sender: UISegmentedControl) {
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "degreeUnitChanged"), object: nil)
	}
	
}
