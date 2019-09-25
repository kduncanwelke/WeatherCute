//
//  AlertsViewController.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 6/7/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit

class AlertsViewController: UIViewController {

	// MARK: IBOutlets

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var severity: UILabel!
	@IBOutlet weak var certainty: UILabel!
	@IBOutlet weak var urgency: UILabel!
	@IBOutlet weak var instruction: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var backButton: UIButton!
	@IBOutlet weak var nextButton: UIButton!
	
	// MARK: Variables
	
	var currentAlertIndex = 0
	var alerts: [AlertInfo] = []
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		currentAlertIndex = 0
		
		backButton.layer.cornerRadius = 15
		nextButton.layer.cornerRadius = 15
		
		loadAlert()
		updateButtons()
    }
	
	// MARK: Custom functions
	
	func loadAlert() {
		print(alerts)
		if alerts.count != 0 {
			var currentAlert = alerts[currentAlertIndex]
			
			titleLabel.text = currentAlert.properties.event
			severity.text = currentAlert.properties.severity
			certainty.text = currentAlert.properties.certainty
			urgency.text = currentAlert.properties.urgency
			instruction.text = currentAlert.properties.instruction.replacingOccurrences(of: "\n", with: " ")
			descriptionLabel.text = currentAlert.properties.headline.replacingOccurrences(of: "\n", with: " ")
			
			if currentAlert.properties.instruction == "" {
				instruction.text = "No instructions at this time"
			}
		}
	}
	
	func updateButtons() {
		if currentAlertIndex == 0 {
			backButton.isEnabled = false
			backButton.backgroundColor = UIColor.clear
		} else {
			backButton.isEnabled = true
			backButton.backgroundColor = UIColor.white
		}
		
		if currentAlertIndex == (alerts.count - 1) || alerts.count == 1 {
			nextButton.isEnabled = false
			nextButton.backgroundColor = UIColor.clear
		} else {
			nextButton.isEnabled = true
			nextButton.backgroundColor = UIColor.white
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

	// MARK: IBActions
	
	@IBAction func backPressed(_ sender: UIButton) {
		currentAlertIndex -= 1
		updateButtons()
		loadAlert()
	}
	
	@IBAction func nextPressed(_ sender: UIButton) {
		currentAlertIndex += 1
		updateButtons()
		loadAlert()
	}
	
	
	@IBAction func dismissPressed(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}
}
