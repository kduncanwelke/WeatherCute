//
//  PageViewController.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 5/30/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit
import CoreData

class PageViewController: UIPageViewController {
	
	// MARK: Variables
	
	var pendingIndex: Int?
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		
		NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: "refresh"), object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(getPrevPage), name: NSNotification.Name(rawValue: "getPrevPage"), object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(getNextPage), name: NSNotification.Name(rawValue: "getNextPage"), object: nil)

		dataSource = self
		delegate = self
		
		createPageViewController()
    }
	
	@objc func refresh() {
		createPageViewController()
	}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
	
	// MARK: Custom functions
	
	@objc func getNextPage() {
		if let currentViewController = self.viewControllers?.first, let nextViewController = dataSource?.pageViewController( self, viewControllerAfter: currentViewController ) {
			setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
		}

		// if not currently on last page, move forward as many pages as there are between the current and the last
		if WeatherLocations.locations.count > 1 {
			let weatherCount = WeatherLocations.locations.count - 1
			for i in 1...weatherCount - PageControllerManager.currentPage {
				if let currentViewController = self.viewControllers?.first, let nextViewController = dataSource?.pageViewController( self, viewControllerAfter: currentViewController ) {
					setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
				}
			}
			
			PageControllerManager.currentPage = WeatherLocations.locations.count - 1
		}
		
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateSectionCount"), object: nil)
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sectionChanged"), object: nil)
	}
	
	@objc func getPrevPage() {
		if PageControllerManager.currentPage == 0 {
			if let currentViewController = self.viewControllers?.first, let nextViewController = dataSource?.pageViewController( self, viewControllerAfter: currentViewController ) {
				setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
			}
			
			deleteLocation()
			
			print("delete: \(PageControllerManager.currentPage)")
			NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refresh"), object: nil)
			NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateSectionCount"), object: nil)
			NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sectionChanged"), object: nil)
		} else if PageControllerManager.currentPage == (WeatherLocations.locations.count - 1) {
			deleteLocation()
			
			PageControllerManager.currentPage -= 1
			NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refresh"), object: nil)
			NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateSectionCount"), object: nil)
			
			// move up a section if last page
			if let currentViewController = self.viewControllers?.first, let previousViewController = dataSource?.pageViewController( self, viewControllerBefore: currentViewController ) {
				setViewControllers([previousViewController], direction: .reverse, animated: true, completion: nil)
			}
			
			NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sectionChanged"), object: nil)
		} else {
			deleteLocation()
		
			NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refresh"), object: nil)
			NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateSectionCount"), object: nil)
			
			// move down a section if not last page
			if let currentViewController = self.viewControllers?.first, let nextViewController = dataSource?.pageViewController( self, viewControllerAfter: currentViewController ) {
				setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
			}
			
			NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sectionChanged"), object: nil)
		}
	}
	
	
	func deleteLocation() {
		var managedContext = CoreDataManager.shared.managedObjectContext
		
		let index = PageControllerManager.currentPage
		print(index)
		managedContext.delete(WeatherLocations.locations[index])
		WeatherLocations.locations.remove(at: index)
		
		do {
			try managedContext.save()
			print("delete successful")
		} catch {
			print("Failed to save")
		}
		
		if WeatherLocations.locations.isEmpty {
			self.dataSource = nil
			PageControllerManager.currentPage = 0
		}
	}
	
	func createPageViewController() {
		if WeatherLocations.locations.count > 0 {
			var contentController = getContentViewController(withIndex: PageControllerManager.currentPage)!
			var contentControllers = [contentController]
			
			self.setViewControllers(contentControllers, direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil)
		}
	}
	
	// create content view
	func getContentViewController(withIndex index: Int) -> ContentViewController? {
		if index < WeatherLocations.locations.count {
			var contentVC = self.storyboard?.instantiateViewController(withIdentifier: "contentVC") as! ContentViewController
			contentVC.itemIndex = index
			contentVC.weather = WeatherLocations.locations[index]
			
			return contentVC
		}
		
		return nil
	}
}

extension PageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		var contentVC = viewController as! ContentViewController
		
		if contentVC.itemIndex > 0 {
			return getContentViewController(withIndex: contentVC.itemIndex - 1)
		} else {
			return nil
		}
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		var contentVC = viewController as! ContentViewController

		if contentVC.itemIndex + 1 < WeatherLocations.locations.count {
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
				PageControllerManager.currentPage = index
				print(PageControllerManager.currentPage)
				NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sectionChanged"), object: nil)
			}
		}
	}
}
