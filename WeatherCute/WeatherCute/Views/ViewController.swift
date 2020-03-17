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
	@IBOutlet weak var tempSegmentedControl: UISegmentedControl!
	
	
	// MARK: Variables
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view
	
		loadSavedLocations()
		updateSectionCount()
		
		NotificationCenter.default.addObserver(self, selector: #selector(sectionChanged), name: NSNotification.Name(rawValue: "sectionChanged"), object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(updateSectionCount), name: NSNotification.Name(rawValue: "updateSectionCount"), object: nil)
        
		NotificationCenter.default.addObserver(self, selector: #selector(alert), name: NSNotification.Name(rawValue: "alert"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(noNetworkAlert), name: NSNotification.Name(rawValue: "noNetworkAlert"), object: nil)
        
		NotificationCenter.default.addObserver(self, selector: #selector(otherAlert), name: NSNotification.Name(rawValue: "otherAlert"), object: nil)
        
        NetworkMonitor.monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("connection successful")
                NetworkMonitor.connection = true
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "networkRestored"), object: nil)
            } else {
                print("no connection")
                NetworkMonitor.connection = false
            }
        }
        
        let queue = DispatchQueue(label: "Monitor")
        NetworkMonitor.monitor.start(queue: queue)
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
	
	@objc func alert() {
		self.showAlert(title: "Network Error", message: Errors.networkError.localizedDescription)
	}
	
	@objc func otherAlert() {
		self.showAlert(title: "Unknown Error", message: Errors.otherError.localizedDescription)
	}
    
    @objc func noNetworkAlert() {
        self.showAlert(title: "No Network", message: Errors.noNetwork.localizedDescription)
    }
	
	@objc func updateSectionCount() {
		if WeatherLocations.locations.isEmpty {
			noDataLabel.isHidden = false
			deleteButton.isHidden = true
			container.isHidden = true
			tempSegmentedControl.isEnabled = false
			tempSegmentedControl.selectedSegmentIndex = 0
		} else {
			noDataLabel.isHidden = true
			deleteButton.isHidden = false
			container.isHidden = false
			tempSegmentedControl.isEnabled = true
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
        if tempSegmentedControl.selectedSegmentIndex == 0 {
            PageControllerManager.currentUnit = .fahrenheit
        } else {
            PageControllerManager.currentUnit = .celsius
        }
        
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "degreeUnitChanged"), object: nil)
	}
	
	@IBAction func aboutPressed(_ sender: UIButton) {
		performSegue(withIdentifier: "showAbout", sender: Any?.self)
	}
	
}
