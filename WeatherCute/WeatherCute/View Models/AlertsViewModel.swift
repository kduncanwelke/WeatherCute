//
//  AlertsViewModel.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 12/10/21.
//  Copyright © 2021 Kate Duncan-Welke. All rights reserved.
//

import Foundation
import UIKit

public class AlertsViewModel {

    var currentAlertIndex = 0

    func resetIndex() {
        currentAlertIndex = 0
    }

    func goBack() {
        currentAlertIndex -= 1
    }

    func goForward() {
        currentAlertIndex += 1
    }

    func configureBackButton() -> (enableButton: Bool, color: UIColor) {
        if currentAlertIndex == 0 {
            return (false, UIColor.clear)
        } else {
            return (true, UIColor.white)
        }
    }

    func configureNextButton() -> (enableButton: Bool, color: UIColor) {
        if let alertsCount = WeatherLocations.alerts[PageControllerManager.currentPage]?.count {
            if (currentAlertIndex == alertsCount - 1) || alertsCount == 1 {
                return (false, UIColor.clear)
            } else {
                return (true, UIColor.white)
            }
        } else {
            return (false, UIColor.clear)
        }
    }

    func getAlertTitle() -> String {
        if let currentAlerts = WeatherLocations.alerts[PageControllerManager.currentPage] {
            var alert = currentAlerts[currentAlertIndex]
            return alert.properties.event
        } else {
            return "No title"
        }
    }

    func getAlertSeverity() -> String {
        if let currentAlerts = WeatherLocations.alerts[PageControllerManager.currentPage] {
            var alert = currentAlerts[currentAlertIndex]
            return alert.properties.severity
        } else {
            return "No data"
        }
    }

    func getAlertCertainty() -> String {
        if let currentAlerts = WeatherLocations.alerts[PageControllerManager.currentPage] {
            var alert = currentAlerts[currentAlertIndex]
            return alert.properties.certainty
        } else {
            return "No data"
        }
    }

    func getAlertUrgency() -> String {
        if let currentAlerts = WeatherLocations.alerts[PageControllerManager.currentPage] {
            var alert = currentAlerts[currentAlertIndex]
            return alert.properties.urgency
        } else {
            return "No data"
        }
    }

    func getInstruction() -> String {
        if let currentAlerts = WeatherLocations.alerts[PageControllerManager.currentPage] {
            var alert = currentAlerts[currentAlertIndex]
            var instruction = alert.properties.instruction.replacingOccurrences(of: "\n", with: " ")

            if instruction == "" {
                return "No instructions at this time"
            } else {
                return instruction
            }
        } else {
            return "No data"
        }
    }

    func getDescription() -> String {
        if let currentAlerts = WeatherLocations.alerts[PageControllerManager.currentPage] {
            var alert = currentAlerts[currentAlertIndex]
            return alert.properties.headline.replacingOccurrences(of: "\n", with: " ")
        } else {
            return "No data"
        }
    }
}
