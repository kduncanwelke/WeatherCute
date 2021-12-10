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

    private let alertsViewModel = AlertsViewModel()
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        alertsViewModel.resetIndex()
		
		backButton.layer.cornerRadius = 15
		nextButton.layer.cornerRadius = 15
		
		loadAlert()
		updateButtons()
    }
	
	// MARK: Custom functions
	
	func loadAlert() {
        titleLabel.text = alertsViewModel.getAlertTitle()
        severity.text = alertsViewModel.getAlertSeverity()
        certainty.text = alertsViewModel.getAlertCertainty()
        urgency.text = alertsViewModel.getAlertUrgency()
        instruction.text = alertsViewModel.getInstruction()
        descriptionLabel.text = alertsViewModel.getDescription()
	}
	
	func updateButtons() {
        var back = alertsViewModel.configureBackButton()
        backButton.isEnabled = back.enableButton
        backButton.backgroundColor = back.color

        var next = alertsViewModel.configureNextButton()
        nextButton.isEnabled = next.enableButton
        nextButton.backgroundColor = next.color
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
        alertsViewModel.goBack()
		updateButtons()
		loadAlert()
	}
	
	@IBAction func nextPressed(_ sender: UIButton) {
        alertsViewModel.goForward()
		updateButtons()
		loadAlert()
	}

	@IBAction func dismissPressed(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}
}
