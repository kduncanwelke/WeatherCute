//
//  AboutViewController.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 6/17/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

	// MARK: IBOutlets
	
	@IBOutlet weak var apiButton: UIButton!
	@IBOutlet weak var privacyPolicyButton: UIButton!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		apiButton.layer.cornerRadius = 15
		privacyPolicyButton.layer.cornerRadius = 15
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
	
	@IBAction func apiButtonPressed(_ sender: UIButton) {
		guard let url = URL(string: "https://www.weather.gov/documentation/services-web-api") else { return }
		UIApplication.shared.open(url, options: [:], completionHandler: nil)
	}
	
	@IBAction func privacyPolicyButtonPressed(_ sender: UIButton) {
		guard let url = URL(string: "http://kduncan-welke.com/weathercuteprivacy.php") else { return }
		UIApplication.shared.open(url, options: [:], completionHandler: nil)
	}
	
	@IBAction func dismissPressed(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}
}
