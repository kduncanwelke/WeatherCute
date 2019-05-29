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
	
	// MARK: Variables
	
	var pageViewController: UIPageViewController?
	var locations = ["chicago", "new york", "miami"]
	var pendingIndex: Int?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		
		createPageViewController()

		DataManager<Current>.fetch() { result in
			switch result {
			case .success(let response):
				print(response)
			case .failure(let error):
				print(error)
			}
		}
	}

	
	// MARK: Custom functions
	
	func createPageViewController() {
		let pageController = self.storyboard?.instantiateViewController(withIdentifier: "pageVC") as! UIPageViewController
		pageController.dataSource = self
		pageController.delegate = self
		
		if locations.count > 0 {
			let contentController = getContentViewController(withIndex: 0)!
			let contentControllers = [contentController]
			
			pageController.setViewControllers(contentControllers, direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil)
		}
		
		pageViewController = pageController
		
		if let page = pageViewController {
			// add to view
			self.addChild(page)
			
			self.view.addSubview(page.view)
			page.didMove(toParent: self)
		}
		
	}
	
	// create content view
	func getContentViewController(withIndex index: Int) -> ContentViewController? {
		if index < locations.count {
			let contentVC = self.storyboard?.instantiateViewController(withIdentifier: "contentVC") as! ContentViewController
			contentVC.itemIndex = index
			contentVC.locationName = locations[index]
			
			return contentVC
		}
		
		return nil
	}
	
	// MARK: IBActions
	
	@IBAction func addLocationTapped(_ sender: UIButton) {
		print("tapped")
		let geocoder = CLGeocoder()
		geocoder.geocodeAddressString("washington dc") { [unowned self] (placemarks, error) in
			if error == nil {
				guard let placemark = placemarks?[0], let location = placemark.location else { return }
				//let locale = MKPlacemark(coordinate: location.coordinate, addressDictionary: "washington dc")
				
				// pass location into search object
				LocationSearch.latitude = location.coordinate.latitude
				LocationSearch.longitude = location.coordinate.longitude
				print(LocationSearch.latitude)
				print(LocationSearch.longitude)
			
				print("did geocoding")
				return
			} else {
				//self.showAlert(title: "Location not found", message: "The location could not be found, please try another selection")
			}
		}
	}
	
}

extension ViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		let contentVC = viewController as! ContentViewController
		
		if contentVC.itemIndex > 0 {
			return getContentViewController(withIndex: contentVC.itemIndex - 1)
		} else {
			return nil
		}
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		let contentVC = viewController as! ContentViewController
		
		if contentVC.itemIndex + 1 < locations.count {
			return getContentViewController(withIndex: contentVC.itemIndex + 1)
		} else {
			return nil
		}
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
		pendingIndex = (pendingViewControllers.first as! ContentViewController).itemIndex
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		if completed {
			let currentIndex = pendingIndex
			if let index = currentIndex {
				self.pageControl.currentPage = index
			}
		}
	}
}
