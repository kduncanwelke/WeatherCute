//
//  ViewController.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 5/29/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	// MARK: IBOutlets
	
	@IBOutlet weak var pageControl: UIPageControl!
	@IBOutlet weak var container: UIView!
	@IBOutlet weak var tempSegmentedControl: UISegmentedControl!
    @IBOutlet weak var addLocationLabel: UILabel!

	// MARK: Variables

    private let viewModel = ViewModel()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view

		NotificationCenter.default.addObserver(self, selector: #selector(sectionChanged), name: NSNotification.Name(rawValue: "sectionChanged"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(updatePageControl), name: NSNotification.Name(rawValue: "updatePageControl"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(networkErrorAlert), name: NSNotification.Name(rawValue: "networkErrorAlert"), object: nil)

        viewModel.loadLocations()

        viewModel.setUpNetworkMonitor()
        updatePageControl()
        addPages()

        if viewModel.getWeatherLocationTotal() != 0 {
            addLocationLabel.isHidden = true
        }
	}
	
	// MARK: Custom functions

    func addPages() {
        if viewModel.getWeatherLocationTotal() != 0 {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addPage"), object: nil)
        }
    }

    @objc func networkErrorAlert() {
        showAlert(title: "Network Error", message: Errors.networkError.localizedDescription)
    }

    @objc func updatePageControl() {
        pageControl.numberOfPages = viewModel.getWeatherLocationTotal()

        if viewModel.getWeatherLocationTotal() != 0 {
            addLocationLabel.isHidden = true
        }
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
