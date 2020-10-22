//
//  ContentViewController.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 5/29/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit
import CoreData

class ContentViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

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
	@IBOutlet weak var alertButton: UIButton!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var collectionViewActivityIndicator: UIActivityIndicatorView!
	
	@IBOutlet weak var detailForecastDay: UILabel!
	@IBOutlet weak var detailForecastLabel: UILabel!
	@IBOutlet weak var detailBackground: UIView!
	@IBOutlet weak var reloadButton: UIButton!
	@IBOutlet weak var reloadActivityIndicator: UIActivityIndicatorView!
	
	// MARK: Variables
	
	var itemIndex = PageControllerManager.currentPage
	var weather: Saved?
	var forecast: [ForecastData] = []
	var forecastLoaded = false
	var currentLoaded = false
	var alertsLoaded = false
	var alertList: [AlertInfo] = []
    
    var currentFinished = false
    var forecastFinished = false
    var alertsFinished = false
	
	var currentTemp: Int?
	var currentDescrip: String?
	var currentHumidity: Int?
	var currentDewpoint: Int?
	var currentHeatOrChill: Int?
	var currentIcon: String?
	var isDay: Bool?
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		detailBackground.layer.cornerRadius = 15
		detailBackground.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
		detailBackground.isHidden = true
		alertButton.isHidden = true
		reloadButton.isHidden = true
		
		collectionView.dataSource = self
		collectionView.delegate = self
		
		NotificationCenter.default.addObserver(self, selector: #selector(reloadCurrent), name: NSNotification.Name(rawValue: "reloadCurrent"), object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(degreeUnitChanged), name: NSNotification.Name(rawValue: "degreeUnitChanged"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(networkRestored), name: NSNotification.Name(rawValue: "networkRestored"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(noNetwork), name: NSNotification.Name(rawValue: "noNetwork"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showNetworkMessage), name: NSNotification.Name(rawValue: "showNetworkMessage"), object: nil)
        
        NetworkMonitor.loadedItems = .none
        
		guard let current = weather, let station = current.station, let obs = current.observation else { return }
		
		location.text = current.name
		
		LocationSearch.latitude = current.latitude
		LocationSearch.longitude = current.longitude
		
		ForecastSearch.gridX = Int(current.xCoord)
		ForecastSearch.gridY = Int(current.yCoord)
		ForecastSearch.station = station
		ForecastSearch.observationStation = obs
		
		currentFrom.text = "Current conditions from \(obs)"
    }
	
	override func viewDidAppear(_ animated: Bool) {
		guard let current = weather, let station = current.station, let obs = current.observation else { return }
		
		location.text = current.name
		
		LocationSearch.latitude = current.latitude
		LocationSearch.longitude = current.longitude
		
		ForecastSearch.gridX = Int(current.xCoord)
		ForecastSearch.gridY = Int(current.yCoord)
		ForecastSearch.station = station
		ForecastSearch.observationStation = obs
        
        loadData()
	}
	
	// MARK: Custom functions
    
    func loadData() {
        if currentLoaded && forecastLoaded && alertsLoaded {
            displayCurrent()
        } else {
            getCurrent()
            getAlerts()
            getForecast()
        }
    }
    
    func checkLoaded() {
        if currentFinished && forecastFinished && alertsFinished {
            NetworkMonitor.loadedItems = .all
        } else if currentFinished && forecastFinished && alertsFinished == false {
            NetworkMonitor.loadedItems = .currentAndForecast
        } else if currentFinished && forecastFinished == false && alertsFinished {
            NetworkMonitor.loadedItems = .currentAndAlerts
        } else if currentFinished && forecastFinished == false && alertsFinished == false {
            NetworkMonitor.loadedItems = .current
        } else if currentFinished == false && forecastFinished && alertsFinished {
            NetworkMonitor.loadedItems = .forecastAndAlerts
        } else if currentFinished == false && forecastFinished && alertsFinished == false {
            NetworkMonitor.loadedItems = .forecast
        } else if currentFinished == false && forecastFinished == false && alertsFinished {
            NetworkMonitor.loadedItems = .alerts
        } else {
            NetworkMonitor.loadedItems = .none
        }
    }
    
    @objc func showNetworkMessage() {
        switch NetworkMonitor.status {
        case .normal:
            print("No problems")
        case .lost:
            // the network was lost
            // only show alerts on currently visible content view to prevent confusion
            if isViewLoaded && itemIndex == PageControllerManager.currentPage {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "noNetworkAlert"), object: nil)
            }
        case .other:
            // there is some other networking error
            // only show alerts on currently visible content view to prevent confusion
            if isViewLoaded && itemIndex == PageControllerManager.currentPage {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "alert"), object: nil)
            }
        }
    }

	func displayCurrent() {
		if let tempy = currentTemp {
			temp.text = " \(tempy)°"
		} else {
			temp.text = "No data"
		}
	
		descrip.text = currentDescrip
		
		if let humid = currentHumidity {
			humidity.text = "\(humid)%"
		} else {
			humidity.text = "No data"
		}
		
		if let dew = currentDewpoint {
			dewpoint.text = "\(dew)°"
		} else {
			dewpoint.text = "No data"
		}
		
		if let heatChill = currentHeatOrChill {
			heatIndex.text = "\(heatChill)°"
		} else {
			heatIndex.text = "N/A"
		}
		
		if let image = currentIcon, let isDayTime = isDay {
			largeImage.image = getImage(icon: image, isDaytime: isDayTime)
		}
	}
    
    @objc func networkRestored() {
        print("network restored")
        loadData()
    }
    
    @objc func noNetwork() {
        // only show alerts on currently visible content view to prevent confusion
        if isViewLoaded && itemIndex == PageControllerManager.currentPage {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "noNetworkAlert"), object: nil)
        }
    }
	
	@objc func degreeUnitChanged() {
		if currentLoaded {
			if PageControllerManager.currentUnit == TemperatureUnit.fahrenheit {
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
			} else if PageControllerManager.currentUnit == TemperatureUnit.celsius {
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
		
		// save changed observation station into core data object
		var managedContext = CoreDataManager.shared.managedObjectContext
		
		guard let current = weather else { return }
		
		current.observation = ForecastSearch.observationStation
		
		do {
			try managedContext.save()
			print("resave successful")
		} catch {
			// this should never be displayed but is here to cover the possibility
			showAlert(title: "Save failed", message: "Notice: Data has not successfully been saved.")
		}
	}
	
	func getCurrent() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
		DataManager<Current>.fetch() { [weak self] result in
			switch result {
			case .success(let response):
				DispatchQueue.main.async {
					guard let data = response.first else {
                        self?.activityIndicator.stopAnimating()
						return
					}
					
					let temp: Int? = {
						if PageControllerManager.currentUnit == TemperatureUnit.celsius {
							if let result = data.properties.temperature.value {
								return Int(result)
							} else {
								return nil
							}
						} else if let tempy = data.properties.temperature.value {
							return self?.convertToFahrenheit(value: Int(tempy))
						} else {
							return nil
						}
					}()
					
					self?.currentTemp = temp
                   
					self?.currentDescrip = data.properties.textDescription
					
					let humidity: Int? = {
						if let result = data.properties.relativeHumidity.value {
							return Int(result)
						} else {
							return nil
						}
					}()
					
					self?.currentHumidity = humidity
						
					let dew: Int? = {
						if PageControllerManager.currentUnit == TemperatureUnit.celsius {
							if let result = data.properties.dewpoint.value {
								return Int(result)
							} else {
								return nil
							}
						} else if let dew = data.properties.dewpoint.value {
							return self?.convertToFahrenheit(value: Int(dew))
						} else {
							return nil
						}
					}()
			
					self?.currentDewpoint = dew
					
					self?.currentHeatOrChill = {
						if let heat = data.properties.heatIndex.value {
							self?.heatIndexLabel.text = "Heat Index"
							
							if PageControllerManager.currentUnit == TemperatureUnit.celsius {
								return Int(heat)
							} else {
								return self?.convertToFahrenheit(value: Int(heat))
							}
						} else if let chill = data.properties.windChill.value {
							self?.heatIndexLabel.text = "Wind Chill"
							
							if PageControllerManager.currentUnit == TemperatureUnit.celsius {
								return Int(chill)
							} else {
								return self?.convertToFahrenheit(value: Int(chill))
							}
						} else {
							return nil
						}
					}()
					
					let separated = data.properties.icon.components(separatedBy: "/")[6]
					let dayNight = data.properties.icon.components(separatedBy: "/")[5]
					
					if dayNight == "day" {
						self?.isDay = true
					} else if dayNight == "night" {
						self?.isDay = false
					}
					
					let icon = separated.components(separatedBy: (","))[0].components(separatedBy: "?")[0]
					self?.currentIcon = icon
					self?.activityIndicator.stopAnimating()
					
					self?.currentLoaded = true
					
					self?.displayCurrent()
				}
			case .failure(let error):
				DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    
					switch error {
					case Errors.networkError:
                        NetworkMonitor.status = .other
                    case Errors.noNetwork:
                        NetworkMonitor.status = .lost
					default:
                        NetworkMonitor.status = .other
					}
                    
                    self?.currentLoaded = true
                    
                    self?.displayCurrent()
				}
			}
		}
        
        currentFinished = true
        checkLoaded()
	}
	
	func getForecast() {
        DispatchQueue.main.async {
            self.collectionViewActivityIndicator.startAnimating()
        }
		DataManager<Forecast>.fetch() { [weak self] result in
			switch result {
			case .success(let response):
				DispatchQueue.main.async {
					guard let data = response.first?.properties.periods else { return }
					
					for forecast in data {
						self?.forecast.append(forecast)
					}
					
					self?.forecastLoaded = true
					
					self?.collectionViewActivityIndicator.stopAnimating()
					self?.collectionView.reloadData()
                    self?.reloadButton.isHidden = false
				}
			case .failure(let error):
				DispatchQueue.main.async {
					self?.forecastLoaded = false
                    self?.collectionViewActivityIndicator.stopAnimating()
                    self?.reloadButton.isHidden = false
                    
					switch error {
					case Errors.networkError:
                        NetworkMonitor.status = .other
                    case Errors.noNetwork:
                        NetworkMonitor.status = .lost
					default:
                        NetworkMonitor.status = .other
					}
				}
			}
		}
        
        forecastFinished = true
        checkLoaded()
	}
	
	func getAlerts() {
		DataManager<Alert>.fetch() { [weak self] result in
			switch result {
			case .success(let response):
				DispatchQueue.main.async {
					guard let data = response.first?.features else { return }
					
					for alert in data {
						self?.alertList.append(alert)
						print(alert)
					}
					
					if data.count > 0 {
						self?.alertButton.isHidden = false
					}
					
					self?.alertsLoaded = true
				}
			case .failure(let error):
				DispatchQueue.main.async {
					self?.alertsLoaded = false
                    
					switch error {
					case Errors.networkError:
                        NetworkMonitor.status = .other
                    case Errors.noNetwork:
                        NetworkMonitor.status = .lost
					default:
                        NetworkMonitor.status = .other
					}
				}
			}
		}
        
        alertsFinished = true
        checkLoaded()
	}
	
	func getForecastText(icon: String) -> String {
		switch icon {
		case Icons.clear.rawValue:
			return "Clear"
		case Icons.fewClouds.rawValue:
			return "Few Clouds"
		case Icons.partlyCloudy.rawValue:
			return "Partly Cloudy"
		case Icons.mostlyCloudy.rawValue:
			return "Mostly Cloudy"
		case Icons.overcast.rawValue:
			return "Overcast"
		case Icons.clearWind.rawValue:
			return "Clear and Windy"
		case  Icons.windFew.rawValue:
			return "Few Clouds, Windy"
		case Icons.partCloudWindy.rawValue:
			return "Partly Cloudy, Windy"
		case Icons.mostCloudyWind.rawValue:
			return "Mostly Cloudy, Windy"
		case Icons.windOvercast.rawValue:
			return "Windy and Overcast"
		case Icons.snow.rawValue:
			return "Snow"
		case Icons.rainSnow.rawValue:
			return "Rain/Snow"
		case Icons.rainSleet.rawValue, Icons.snowSleet.rawValue:
			return "Rain/Sleet"
		case Icons.freezingRain.rawValue:
			return "Freezing Rain"
		case Icons.rainFreezing.rawValue:
			return "Rain/Freezing Rain"
		case Icons.snowFreezing.rawValue:
			return "Freezing Rain/Snow"
		case Icons.sleet.rawValue:
			return "Sleet"
		case Icons.rain.rawValue:
			return "Rain"
		case Icons.rainshowers.rawValue, Icons.rainshowersHi.rawValue:
			return "Rain Showers"
		case Icons.thunderstorm.rawValue, Icons.thunderstormScattered.rawValue, Icons.thunderstormHi.rawValue:
			return "Thunderstorms"
		case Icons.tornado.rawValue:
			return "Tornado"
		case Icons.hurricane.rawValue:
			return "Hurricane"
		case Icons.tropicalStorm.rawValue:
			return "Tropical Storm"
		case Icons.smoke.rawValue:
			return "Smoke"
		case Icons.haze.rawValue:
			return "Haze"
		case Icons.fog.rawValue:
			return "Fog"
		case Icons.hot.rawValue:
			return "Hot"
		case Icons.cold.rawValue:
			return "Cold"
		case Icons.blizzard.rawValue:
			return "Blizzard"
		default:
			return "No data"
		}
	}
	
	func getImage(icon: String, isDaytime: Bool) -> UIImage? {
		if isDaytime {
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
		} else {
			switch icon {
			case Icons.clear.rawValue:
				return UIImage(named: "nightsunny")
			case Icons.fewClouds.rawValue, Icons.partlyCloudy.rawValue:
				return UIImage(named: "nightpartlycloudy")
			case Icons.mostlyCloudy.rawValue, Icons.overcast.rawValue:
				return UIImage(named: "nightcloudy")
			case Icons.clearWind.rawValue, Icons.windFew.rawValue:
				return UIImage(named: "nightclearwindy")
			case Icons.partCloudWindy.rawValue, Icons.mostCloudyWind.rawValue, Icons.windOvercast.rawValue:
				return UIImage(named: "nightcloudywindy")
			case Icons.snow.rawValue:
				return UIImage(named: "nightsnow")
			case Icons.rainSnow.rawValue, Icons.rainSleet.rawValue, Icons.snowSleet.rawValue:
				return UIImage(named: "nightmix")
			case Icons.freezingRain.rawValue, Icons.rainFreezing.rawValue, Icons.snowFreezing.rawValue, Icons.sleet.rawValue:
				return UIImage(named: "nightsleet")
			case Icons.rain.rawValue, Icons.rainshowers.rawValue, Icons.rainshowersHi.rawValue:
				return UIImage(named: "nightrain")
			case Icons.thunderstorm.rawValue, Icons.thunderstormScattered.rawValue, Icons.thunderstormHi.rawValue:
				return UIImage(named: "nightthunderstorm")
			case Icons.tornado.rawValue:
				return UIImage(named: "nighttornado")
			case Icons.hurricane.rawValue, Icons.tropicalStorm.rawValue:
				return UIImage(named: "nighthurricane")
			case Icons.smoke.rawValue:
				return UIImage(named: "nightsmoke")
			case Icons.haze.rawValue, Icons.fog.rawValue:
				return UIImage(named: "nighthaze")
			case Icons.hot.rawValue:
				return UIImage(named: "nighthot")
			case Icons.cold.rawValue:
				return UIImage(named: "nightcold")
			case Icons.blizzard.rawValue:
				return UIImage(named: "nightblizzard")
			default:
				return UIImage(named: "none")
			}
		}
	}


    // MARK: Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.destination is AlertsViewController {
			let destinationViewController = segue.destination as? AlertsViewController
			destinationViewController?.alerts = alertList
		}
	}
	
	// MARK: IBActions
	
	@IBAction func changeButtonPressed(_ sender: UIButton) {
		performSegue(withIdentifier: "changeStation", sender: Any?.self)
	}
	
	@IBAction func alertButtonPressed(_ sender: UIButton) {
		performSegue(withIdentifier: "viewAlerts", sender: Any?.self)
	}
	
	@IBAction func reload(_ sender: UIButton) {
		reloadButton.setImage(UIImage(named: "loading"), for: .normal)
		reloadActivityIndicator.startAnimating()
		reloadButton.isEnabled = false
		print("reload")
		forecast.removeAll()
		alertList.removeAll()
		
		getAlerts()
		getCurrent()
		getForecast()
		reloadActivityIndicator.stopAnimating()
		reloadButton.setImage(UIImage(named: "reload"), for: .normal)
		reloadButton.isEnabled = true
	}
	
}

extension ContentViewController: UICollectionViewDataSource, CollectionViewTapDelegate {
	func longPress(sender: ForecastCollectionViewCell, state: UIGestureRecognizer.State) {
		
        if state == .began {
			let path = self.collectionView.indexPath(for: sender)
			if let selected = path {
				detailBackground.popUp()
				detailForecastDay.text = forecast[selected.row].name
				detailForecastLabel.text = forecast[selected.row].detailedForecast
			}
        } else if state == .ended {
            detailBackground.goDown()
        }
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return forecast.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "forecastCell", for: indexPath) as! ForecastCollectionViewCell
	
		if forecastLoaded {
			cell.cellTitle.text = forecast[indexPath.row].name
			
			if PageControllerManager.currentUnit == TemperatureUnit.fahrenheit {
				cell.cellTemp.text = "\(forecast[indexPath.row].temperature)°"
			} else if PageControllerManager.currentUnit == TemperatureUnit.celsius {
				let newTemp = convertToCelsius(value: forecast[indexPath.row].temperature)
				cell.cellTemp.text = "\(newTemp)°"
			}
			
			let separated = forecast[indexPath.row].icon.components(separatedBy: "/")[6]
			
			let icon = separated.components(separatedBy: (","))[0].components(separatedBy: "?")[0]
		
			cell.cellImage.image = getImage(icon: icon, isDaytime: forecast[indexPath.row].isDaytime)
			
			cell.descrip.text = getForecastText(icon: icon)
			
			cell.collectionDelegate = self
		}
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		let cellWidth : CGFloat = 145.0
		
		let numberOfCells = floor(self.view.frame.size.width / cellWidth)
		let edgeInsets = (self.view.frame.size.width - (numberOfCells * cellWidth)) / (numberOfCells + 1)
		
		return UIEdgeInsets(top: 0, left: edgeInsets, bottom: 20, right: edgeInsets)
	}
}

