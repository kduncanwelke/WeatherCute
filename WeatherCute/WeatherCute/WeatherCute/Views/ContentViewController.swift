//
//  ContentViewController.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 5/29/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController {

	// MARK: IBOutlets
	
	@IBOutlet weak var location: UILabel!
	@IBOutlet weak var temp: UILabel!
	@IBOutlet weak var descrip: UILabel!
	@IBOutlet weak var dewpoint: UILabel!
	@IBOutlet weak var windChill: UILabel!
	@IBOutlet weak var heatIndex: UILabel!
	
	// MARK: Variables
	
	var itemIndex = 0
	var weather: SavedLocation?
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		guard let current = weather else { return }
		
		location.text = current.name
		
		LocationSearch.latitude = current.latitude
		LocationSearch.longitude = current.longitude
		
		ForecastSearch.gridX = current.xCoord!
		ForecastSearch.gridY = current.yCoord!
		ForecastSearch.station = current.station!
		ForecastSearch.observationStation = current.observationStation!
		
		getCurrent()
    }
	
	
	// MARK: Custom functions
	
	func getCurrent() {
		DataManager<Current>.fetch() { [unowned self] result in
			switch result {
			case .success(let response):
				DispatchQueue.main.async {
					guard let data = response.first else { return }
					
					let temp = (Int(data.properties.temperature.value) * 9/5) + 32
					self.temp.text = "\(temp)°"
						
					self.descrip.text = data.properties.textDescription
						
					let dew = (Int(data.properties.dewpoint.value) * 9/5) + 32
					self.dewpoint.text = "\(dew)"
						
					self.windChill.text = {
						if let chill = data.properties.windChill.value  {
							return "\(Int(chill * 9/5) + 32)°"
						} else {
							return "N/A"
						}
					}()
					self.heatIndex.text = {
						if let heat = data.properties.heatIndex.value {
							return "\(Int(heat * 9/5) + 32)°"
						} else {
							return "N/A"
						}
					}()
					print(data)
				}
			case .failure(let error):
				print(error)
			}
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
