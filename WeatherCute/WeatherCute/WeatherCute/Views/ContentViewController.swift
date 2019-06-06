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
	@IBOutlet weak var humidity: UILabel!
	@IBOutlet weak var dewpoint: UILabel!
	@IBOutlet weak var heatIndex: UILabel!
	@IBOutlet weak var heatIndexLabel: UILabel!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var currentFrom: UILabel!
	@IBOutlet weak var largeImage: UIImageView!
	
	
	// MARK: Variables
	
	var itemIndex = PageControllerManager.currentPage
	var weather: Saved?
	var forecast: [ForecastData] = []
	var forecastLoaded = false
	var currentLoaded = false
	
	var unit = TemperatureUnit.fahrenheit
	
	var currentTemp: Int?
	var currentDescrip: String?
	var currentHumidity: String?
	var currentDewpoint: Int?
	var currentHeatOrChill: Int?
	var currentIcon: String?
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
		collectionView.dataSource = self
		
		NotificationCenter.default.addObserver(self, selector: #selector(reloadCurrent), name: NSNotification.Name(rawValue: "reloadCurrent"), object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(degreeUnitChanged), name: NSNotification.Name(rawValue: "degreeUnitChanged"), object: nil)
		
		guard let current = weather, let station = current.station, let obs = current.observation else { return }
		
		location.text = current.name
		
		LocationSearch.latitude = current.latitude
		LocationSearch.longitude = current.longitude
		
		ForecastSearch.gridX = Int(current.xCoord)
		ForecastSearch.gridY = Int(current.yCoord)
		ForecastSearch.station = station
		ForecastSearch.observationStation = obs
		
		currentFrom.text = "Current conditions from \(obs)"
		
		if currentLoaded && forecastLoaded {
			displayCurrent()
		} else {
			getCurrent()
			getForecast()
		}
    }
	
	
	// MARK: Custom functions
	
	func displayCurrent() {
		if let tempy = currentTemp {
			temp.text = " \(tempy)°"
		}
		
		descrip.text = currentDescrip
		humidity.text = currentHumidity
		
		if let dew = currentDewpoint {
			dewpoint.text = "\(dew)°"
		}
		
		if let heatChill = currentHeatOrChill {
			heatIndex.text = "\(heatChill)°"
		} else {
			heatIndex.text = "N/A"
		}
		
		if let image = currentIcon {
			largeImage.image = getImage(icon: image)
		}
	}
	
	@objc func degreeUnitChanged() {
		if unit == TemperatureUnit.fahrenheit {
			unit = TemperatureUnit.celsius
		} else if unit == TemperatureUnit.celsius {
			unit = TemperatureUnit.fahrenheit
		}
		
		if currentLoaded {
			if unit == TemperatureUnit.fahrenheit {
				if let current = currentTemp {
					let newTemp = convertToFahrenheit(value: current)
					currentTemp = newTemp
				}
				
				if let currentDew = currentDewpoint {
					let newDew = convertToFahrenheit(value: currentDew)
					currentDewpoint = newDew
				}
				
				if let currentHeatChill = currentHeatOrChill {
					let newHeatChill = convertToFahrenheit(value: currentHeatChill)
					currentHeatOrChill = newHeatChill
				}
			} else if unit == TemperatureUnit.celsius {
				if let current = currentTemp {
					let newTemp = convertToCelsius(value: current)
					currentTemp = newTemp
				}
				
				if let currentDew = currentDewpoint {
					let newDew = convertToCelsius(value: currentDew)
					currentDewpoint = newDew
				}
				
				if let currentHeatChill = currentHeatOrChill {
					let newHeatChill = convertToCelsius(value: currentHeatChill)
					currentHeatOrChill = newHeatChill
				}
			}
			
			displayCurrent()
			collectionView.reloadData()
		}
	}
	
	func convertToFahrenheit(value: Int) -> Int {
		let result = (value * 9/5) + 32
		return Int(result)
	}
	
	func convertToCelsius(value: Int) -> Int {
		let double = Double(value)
		let result = (double - 32) / 1.8
		return Int(result)
	}
	
	@objc func reloadCurrent() {
		currentFrom.text = "Current conditions from \(ForecastSearch.observationStation)"
		getCurrent()
	}
	
	func getCurrent() {
		DataManager<Current>.fetch() { [weak self] result in
			switch result {
			case .success(let response):
				DispatchQueue.main.async {
					guard let data = response.first else { return }
					
					let temp: Int = {
						if self?.unit == TemperatureUnit.celsius {
							return Int(data.properties.temperature.value)
						} else {
							let tempy = Int(data.properties.temperature.value)
							return self?.convertToFahrenheit(value: tempy) ?? 0
						}
					}()
					
					self?.currentTemp = temp
					
					self?.currentDescrip = data.properties.textDescription
					
					let humidity = Int(data.properties.relativeHumidity.value)
					self?.currentHumidity = "\(humidity)%"
						
					let dew: Int = {
						if self?.unit == TemperatureUnit.celsius {
							return Int(data.properties.dewpoint.value)
						} else {
							let dew = Int(data.properties.dewpoint.value)
							return self?.convertToFahrenheit(value: dew) ?? 0
						}
					}()
			
					self?.currentDewpoint = dew
					
					self?.currentHeatOrChill = {
						if let heat = data.properties.heatIndex.value {
							self?.heatIndexLabel.text = "Heat Index"
							
							if self?.unit == TemperatureUnit.celsius {
								return Int(heat)
							} else {
								return self?.convertToFahrenheit(value: Int(heat))
							}
						} else if let chill = data.properties.windChill.value {
							self?.heatIndexLabel.text = "Wind Chill"
							
							if self?.unit == TemperatureUnit.celsius {
								return Int(chill)
							} else {
								return self?.convertToFahrenheit(value: Int(chill))
							}
						} else {
							return nil
						}
					}()
					
					let separated =  data.properties.icon.components(separatedBy: "/")[6]
					
					let icon = separated.components(separatedBy: (","))[0].components(separatedBy: "?")[0]
					self?.currentIcon = icon
					
					self?.currentLoaded = true
					
					self?.displayCurrent()
				}
			case .failure(let error):
				print(error)
			}
		}
	}
	
	func getForecast() {
		DataManager<Forecast>.fetch() { result in
			switch result {
			case .success(let response):
				DispatchQueue.main.async {
					guard let data = response.first?.properties.periods else { return }
					
					for forecast in data {
						self.forecast.append(forecast)
					}
					
					self.forecastLoaded = true
					self.collectionView.reloadData()
				}
			case .failure(let error):
				print(error)
			}
		}
	}
	
	func getImage(icon: String) -> UIImage? {
		switch icon {
		case Icons.clear.rawValue:
			return UIImage(named: "sunny")
		case Icons.fewClouds.rawValue, Icons.partlyCloudy.rawValue:
			return UIImage(named: "partlycloudy")
		case Icons.mostlyCloudy.rawValue, Icons.overcast.rawValue:
			return UIImage(named: "cloudy")
		case Icons.clearWind.rawValue, Icons.windFew.rawValue:
			return UIImage(named: "clearwindy")
		case Icons.partCloudWindy.rawValue, Icons.mostCloudyWind.rawValue, Icons.windOvercast.rawValue:
			return UIImage(named: "cloudywindy")
		case Icons.snow.rawValue:
			return UIImage(named: "snow")
		case Icons.rainSnow.rawValue, Icons.rainSleet.rawValue, Icons.snowSleet.rawValue:
			return UIImage(named: "mix")
		case Icons.freezingRain.rawValue, Icons.rainFreezing.rawValue, Icons.snowFreezing.rawValue, Icons.sleet.rawValue:
			return UIImage(named: "sleet")
		case Icons.rain.rawValue, Icons.rainshowers.rawValue, Icons.rainshowersHi.rawValue:
			return UIImage(named: "rain")
		case Icons.thunderstorm.rawValue, Icons.thunderstormScattered.rawValue, Icons.thunderstormHi.rawValue:
			return UIImage(named: "thunderstorm")
		case Icons.tornado.rawValue:
			return UIImage(named: "tornado")
		case Icons.hurricane.rawValue, Icons.tropicalStorm.rawValue:
			return UIImage(named: "hurricane")
		case Icons.smoke.rawValue:
			return UIImage(named: "smoke")
		case Icons.haze.rawValue, Icons.fog.rawValue:
			return UIImage(named: "haze")
		case Icons.hot.rawValue:
			return UIImage(named: "hot")
		case Icons.cold.rawValue:
			return UIImage(named: "cold")
		case Icons.blizzard.rawValue:
			return UIImage(named: "blizzard")
		default:
			return UIImage(named: "none")
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
	
	@IBAction func changeButtonPressed(_ sender: UIButton) {
		performSegue(withIdentifier: "changeStation", sender: Any?.self)
	}

}

extension ContentViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return forecast.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "forecastCell", for: indexPath) as! ForecastCollectionViewCell
		
		if forecastLoaded {
			cell.cellTitle.text = forecast[indexPath.row].name
			
			if unit == TemperatureUnit.fahrenheit {
				cell.cellTemp.text = "\(forecast[indexPath.row].temperature)°"
			} else if unit == TemperatureUnit.celsius {
				let newTemp = convertToCelsius(value: forecast[indexPath.row].temperature)
				cell.cellTemp.text = "\(newTemp)°"
			}
			
			let separated = forecast[indexPath.row].icon.components(separatedBy: "/")[6]
			
			let icon = separated.components(separatedBy: (","))[0].components(separatedBy: "?")[0]
		
			cell.cellImage.image = getImage(icon: icon)
		}
		
		return cell
	}
	
}
