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
	
	private let pageControllerViewModel = PageControllerViewModel()
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        NotificationCenter.default.addObserver(self, selector: #selector(addPage), name: NSNotification.Name(rawValue: "addPage"), object: nil)

		NotificationCenter.default.addObserver(self, selector: #selector(getPrevPage), name: NSNotification.Name(rawValue: "getPrevPage"), object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(getNextPage), name: NSNotification.Name(rawValue: "getNextPage"), object: nil)

		dataSource = self
		delegate = self
		
		createPageViewController()
    }

	@objc func addPage() {
		createPageViewController()
	}

    func createPageViewController() {
        print("add page")
        if pageControllerViewModel.getWeatherLocationTotal() > 0 {
            var contentController = getContentViewController(withIndex: pageControllerViewModel.getCurrentPage())!
            var contentControllers = [contentController]

            self.setViewControllers(contentControllers, direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
        }
    }

    // create content view
    func getContentViewController(withIndex index: Int) -> ContentViewController? {
        if index < pageControllerViewModel.getWeatherLocationTotal() {
            var contentVC = self.storyboard?.instantiateViewController(withIdentifier: "contentVC") as! ContentViewController

            return contentVC
        }

        return nil
    }

	@objc func getNextPage() {
        print("get next")
		if let currentViewController = self.viewControllers?.first, let nextViewController = dataSource?.pageViewController( self, viewControllerAfter: currentViewController ) {
			setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
		}

		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatePageControl"), object: nil)
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sectionChanged"), object: nil)
	}
	
	@objc func getPrevPage() {
        if pageControllerViewModel.getCurrentPage() == 0 {
            print("first")
            if let currentViewController = self.viewControllers?.first {
                setViewControllers([currentViewController], direction: .reverse, animated: false, completion: nil)
            }

            // first item needs reloading
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshContent"), object: nil)
			NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatePageControl"), object: nil)
			NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sectionChanged"), object: nil)
        } else if pageControllerViewModel.getCurrentPage() == pageControllerViewModel.getWeatherLocationTotal() {

            pageControllerViewModel.setCurrentPage(page: pageControllerViewModel.getCurrentPage()-1)
			print("last page")

            // only one location left, just set to first viewcontroller
            if WeatherLocations.locations.count == 1 {
                print("count one")
                if let currentViewController = self.viewControllers?.first {
                    setViewControllers([currentViewController], direction: .reverse, animated: false, completion: nil)
                }
            } else {
                // move up a section as this is not last page and there are more than one
                if let currentViewController = self.viewControllers?.first, let nextViewController = dataSource?.pageViewController( self, viewControllerBefore: currentViewController ) {
                    setViewControllers([nextViewController], direction: .reverse, animated: false, completion: nil)
                }
            }

            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatePageControl"), object: nil)
			NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sectionChanged"), object: nil)
		} else {
            // move down a section since this is not last page
            print("not last")

			if let currentViewController = self.viewControllers?.first, let nextViewController = dataSource?.pageViewController( self, viewControllerBefore: currentViewController ) {
				setViewControllers([nextViewController], direction: .reverse, animated: false, completion: nil)
			}

            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "upatePageControl"), object: nil)
			NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sectionChanged"), object: nil)
		}
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

extension PageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if pageControllerViewModel.getCurrentPage() > 0 {
            
            pageControllerViewModel.setScrollDirection(direction: .left)

            pageControllerViewModel.setPendingPage(page: pageControllerViewModel.getCurrentPage() - 1)
            print("left")
            print(PageControllerManager.currentPage)
            print(PageControllerManager.pendingIndex)

            return getContentViewController(withIndex: pageControllerViewModel.getCurrentPage() - 1)
        } else {
            return nil
        }
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if pageControllerViewModel.getCurrentPage() + 1 < pageControllerViewModel.getWeatherLocationTotal() {
            
            pageControllerViewModel.setScrollDirection(direction: .right)

            pageControllerViewModel.setPendingPage(page: pageControllerViewModel.getCurrentPage() + 1)
            print("right")
            print(PageControllerManager.currentPage)
            print(PageControllerManager.pendingIndex)

            return getContentViewController(withIndex: pageControllerViewModel.getCurrentPage() + 1)
        } else {
            return nil
        }
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if pageControllerViewModel.getScrollDirection() == .left {
            return
        }
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if pageControllerViewModel.getWeatherLocationTotal() <= 1 {
                return
            }

            var oldIndex = pageControllerViewModel.getCurrentPage()

            pageControllerViewModel.setCurrentPage(page: pageControllerViewModel.getPendingIndex())
            pageControllerViewModel.setPendingPage(page: oldIndex)
            
            print("did finish animating")

            // call viewdidload on visible viewcontroller
            self.viewControllers?.first?.viewWillAppear(true)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sectionChanged"), object: nil)
        }
	}
}
