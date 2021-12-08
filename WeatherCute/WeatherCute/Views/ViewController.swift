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
	@IBOutlet weak var tempSegmentedControl: UISegmentedControl!
	
	// MARK: Variables

    private let viewModel = ViewModel()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view

        NotificationCenter.default.addObserver(self, selector: #selector(retrieveData), name: NSNotification.Name(rawValue: "retrieveData"), object: nil)

		NotificationCenter.default.addObserver(self, selector: #selector(sectionChanged), name: NSNotification.Name(rawValue: "sectionChanged"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(updatePageControl), name: NSNotification.Name(rawValue: "updatePageControl"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(updateSegment), name: NSNotification.Name(rawValue: "updateSegment"), object: nil)

        // ??
        
		NotificationCenter.default.addObserver(self, selector: #selector(alert), name: NSNotification.Name(rawValue: "alert"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(noNetworkAlert), name: NSNotification.Name(rawValue: "noNetworkAlert"), object: nil)

        viewModel.loadLocations()
        viewModel.loadUnit()

        updatePageControl()
        viewModel.setUpNetworkMonitor()
	}
	
	// MARK: Custom functions

    @objc func updateSegment() {
        tempSegmentedControl.selectedSegmentIndex = viewModel.getSegment()
    }

    @objc func retrieveData() {
        viewModel.getAll()
    }

    @objc func updatePageControl() {
        pageControl.numberOfPages = viewModel.getWeatherLocationTotal()
    }
	
	@objc func alert() {
		self.showAlert(title: "Network Error", message: Errors.networkError.localizedDescription)
	}
	
    @objc func noNetworkAlert() {
        self.showAlert(title: "No Network", message: Errors.noNetwork.localizedDescription)
    }
    
	@objc func sectionChanged() {
        pageControl.currentPage = viewModel.getCurrentPage()
		print("section changed")
		print(PageControllerManager.currentPage)
	}

	@IBAction func addPressed(_ sender: UIButton) {
		performSegue(withIdentifier: "addLocation", sender: Any?.self)
	}

	@IBAction func degreeSegmentChanged(_ sender: UISegmentedControl) {
        viewModel.changeUnit(index: tempSegmentedControl.selectedSegmentIndex)

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "degreeUnitChanged"), object: nil)
	}

    @IBAction func editPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "edit", sender: Any?.self)
    }
	
	@IBAction func aboutPressed(_ sender: UIButton) {
		performSegue(withIdentifier: "showAbout", sender: Any?.self)
	}
	
}
