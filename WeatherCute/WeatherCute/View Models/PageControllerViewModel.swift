//
//  PageControllerViewModel.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 12/8/21.
//  Copyright © 2021 Kate Duncan-Welke. All rights reserved.
//

import Foundation

public class PageControllerViewModel {

    func getWeatherLocationTotal() -> Int {
        return WeatherLocations.locations.count
    }

    func getCurrentPage() -> Int {
        return PageControllerManager.currentPage
    }

    func getPendingIndex() -> Int {
        return PageControllerManager.pendingIndex
    }

    func setPendingPage(page: Int) {
        PageControllerManager.pendingIndex = page
    }

    func setCurrentPage(page: Int) {
        PageControllerManager.currentPage = page
    }

    func setScrollDirection(direction: ScrollDirection) {
        PageControllerManager.direction = direction
    }

    func getScrollDirection() -> ScrollDirection {
        return PageControllerManager.direction
    }
}
