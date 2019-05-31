//
//  PageViewController.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 5/30/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController {
	
	// MARK: Variables
	
	var pendingIndex: Int?
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		
		NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: "refresh"), object: nil)

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
	
	func createPageViewController() {
		if WeatherLocations.locations.count > 0 {
			let contentController = getContentViewController(withIndex: 0)!
			let contentControllers = [contentController]
			print("called")
			
			self.setViewControllers(contentControllers, direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil)
		}
	}
	
	// create content view
	func getContentViewController(withIndex index: Int) -> ContentViewController? {
		if index < WeatherLocations.locations.count {
			let contentVC = self.storyboard?.instantiateViewController(withIdentifier: "contentVC") as! ContentViewController
			contentVC.itemIndex = index
			contentVC.weather = WeatherLocations.locations[index]
			
			return contentVC
		}
		
		return nil
	}

}

extension PageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
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
				NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sectionChanged"), object: nil)
			}
		}
	}
}
