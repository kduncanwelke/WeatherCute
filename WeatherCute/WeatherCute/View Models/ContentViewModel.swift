//
//  ContentViewModel.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 12/8/21.
//  Copyright © 2021 Kate Duncan-Welke. All rights reserved.
//

import Foundation
import UIKit

public class ContentViewModel {

    weak var delegate: RetryDelegate?

    func getLocationsCount() -> Int {
        return WeatherLocations.locations.count
    }

    func setSearchParameters() {
        print("set search")
        print(PageControllerManager.currentPage)
        var location = WeatherLocations.locations[PageControllerManager.currentPage]
        
        LocationSearch.latitude = location.latitude
        LocationSearch.longitude = location.longitude

        ForecastSearch.gridX = Int(location.xCoord)
        ForecastSearch.gridY = Int(location.yCoord)
        ForecastSearch.station = location.station ?? ""
        ForecastSearch.observationStation = location.observation ?? ""
    }

    func getWeatherData(completion: @escaping () -> Void) {
        DataManager<Current>.fetch() { result in
            print("fetch weather")
            switch result {
            case .success(let response):
                if let data = response.first {
                    WeatherLocations.currentConditions[PageControllerManager.currentPage] = data
                    print("for page \(PageControllerManager.currentPage)")
                }

                //print(response)
                completion()
            case .failure(let error):
                print(error)
                completion()
            }
        }
    }

    func getForecastData(retried: Bool, completion: @escaping () -> Void) {
        DataManager<Forecast>.fetch() { [weak self] result in
            print("fetch forecast")
            switch result {
            case .success(let response):
                if let data = response.first?.properties.periods {
                    var forecasts: [ForecastData] = []

                    for forecast in data {
                        forecasts.append(forecast)
                    }

                    WeatherLocations.forecasts[PageControllerManager.currentPage] = forecasts
                }

                if retried {
                    self?.delegate?.showActivityIndicator(display: false)
                }
                //print(response)
                completion()
            case .failure(let error):
                print(error)
                completion()

                if retried == false {
                    if error as? Errors == Errors.unexpectedProblem {
                        print("retry")
                        // retry 500 error request; per NOAA ServiceNow support 500 errors can typically be fixed with a second request (use brief wait to avoid rate limit)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self?.delegate?.showActivityIndicator(display: true)
                            self?.getForecastData(retried: true, completion: completion)
                        }
                    }
                }
            }
        }
    }

    func getAlerts(completion: @escaping () -> Void) {
        DataManager<Alert>.fetch() { [weak self] result in
            print("fetch alerts")
            switch result {
            case .success(let response):
                if let data = response.first?.features {
                    var alertList: [AlertInfo] = []

                    for alert in data {
                        alertList.append(alert)
                    }

                    WeatherLocations.alerts[PageControllerManager.currentPage] = alertList
                }

                //print(response)
                completion()
            case .failure(let error):
                print(error)
                completion()
            }
        }
    }

    func isLoaded() -> Bool {
        if WeatherLocations.currentConditions[PageControllerManager.currentPage] != nil && !(WeatherLocations.forecasts[PageControllerManager.currentPage]?.isEmpty ?? true) && WeatherLocations.alerts[PageControllerManager.currentPage] != nil  {
            return true
        } else {
            return false
        }
    }

    // helpers

    func hasNetwork() -> Bool {
        return NetworkMonitor.connection
    }

    func convertToFahrenheit(value: Double) -> Int {
        let result = (value * 9/5) + 32
        return Int(result)
    }

    func convertToCelsius(value: Double) -> Int {
        let result = (value - 32) / 1.8
        return Int(result)
    }

    // view config

    func isDayCurrently() -> Bool?  {
        if let weatherIcon = WeatherLocations.currentConditions[PageControllerManager.currentPage]?.properties.icon {

            let dayNight = weatherIcon.components(separatedBy: "/")[5]

            if dayNight == "day" {
                return true
            } else if dayNight == "night" {
                return false
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

    func getLocationName() -> String {
        return WeatherLocations.locations[PageControllerManager.currentPage].name ?? "Unknown"
    }

    // widget version
    func getLocationName(useStub: Bool) -> String {
        if useStub {
            return "Your Location"
        } else {
            return WeatherLocations.locations[PageControllerManager.currentPage].name ?? "Unknown"
        }
    }

    func getObservationName() -> String {
        return "Current conditions from \(WeatherLocations.locations[PageControllerManager.currentPage].observation ?? "")"
    }

    func getCurrentTemp() -> String {
        if let current = WeatherLocations.currentConditions[PageControllerManager.currentPage] {
            if let temp = current.properties.temperature.value {
                switch Temp.currentUnit {
                case .fahrenheit:
                    var fahrenheit = Int(convertToFahrenheit(value: temp))
                    return " \(fahrenheit)°"
                case .celsius:
                    return " \(Int(temp))°"
                }
            } else {
                return "No data"
            }
        } else {
            return "No data"
        }
    }

    // widget version
    func getCurrentTemp(useStub: Bool) -> String {
        if useStub {
            return " 75°"
        } else {
            if let current = WeatherLocations.currentConditions[PageControllerManager.currentPage] {
                if let temp = current.properties.temperature.value {
                    switch Temp.currentUnit {
                    case .fahrenheit:
                        var fahrenheit = Int(convertToFahrenheit(value: temp))
                        return " \(fahrenheit)°"
                    case .celsius:
                        return " \(Int(temp))°"
                    }
                } else {
                    return "No data"
                }
            } else {
                return "No data"
            }
        }
    }

    func getCurrentDescription() -> String {
        if let current = WeatherLocations.currentConditions[PageControllerManager.currentPage] {
            if current.properties.textDescription == "" {
                return "No current reporting"
            } else {
                return current.properties.textDescription
            }
        } else {
            return "No current reporting"
        }
    }

    // widget version
    func getCurrentDescription(useStub: Bool) -> String {
        if useStub {
            return "Partly Cloudy"
        } else {
            if let current = WeatherLocations.currentConditions[PageControllerManager.currentPage] {
                if current.properties.textDescription == "" {
                    return "No current reporting"
                } else {
                    return current.properties.textDescription
                }
            } else {
                return "No current reporting"
            }
        }
    }

    func getCurrentHumidity() -> String {
        if let current = WeatherLocations.currentConditions[PageControllerManager.currentPage] {
            if let humidity = current.properties.relativeHumidity.value {
                return "\(Int(humidity))%"
            } else {
                return "No data"
            }
        } else {
            return "No data"
        }
    }

    // widget version
    func getCurrentHumidity(useStub: Bool) -> String {
        if useStub {
            return "50%"
        } else {
            if let current = WeatherLocations.currentConditions[PageControllerManager.currentPage] {
                if let humidity = current.properties.relativeHumidity.value {
                    return "\(Int(humidity))%"
                } else {
                    return "No data"
                }
            } else {
                return "No data"
            }
        }
    }

    func getCurrentDewpoint() -> String {
        if let current = WeatherLocations.currentConditions[PageControllerManager.currentPage] {
            if let dew = current.properties.dewpoint.value {
                switch Temp.currentUnit {
                case .fahrenheit:
                    var fahrenheit = Int(convertToFahrenheit(value: dew))
                    return " \(fahrenheit)°"
                case .celsius:
                    return " \(Int(dew))°"
                }
            } else {
                return "No data"
            }
        } else {
            return "No data"
        }
    }

    // widget version
    func getCurrentDewpoint(useStub: Bool) -> String {
        if useStub {
            return " 60°"
        } else {
            if let current = WeatherLocations.currentConditions[PageControllerManager.currentPage] {
                if let dew = current.properties.dewpoint.value {
                    switch Temp.currentUnit {
                    case .fahrenheit:
                        var fahrenheit = Int(convertToFahrenheit(value: dew))
                        return " \(fahrenheit)°"
                    case .celsius:
                        return " \(Int(dew))°"
                    }
                } else {
                    return "No data"
                }
            } else {
                return "No data"
            }
        }
    }

    func getCurrentHeatChill() -> String {
        if let current = WeatherLocations.currentConditions[PageControllerManager.currentPage] {
            if let heat = current.properties.heatIndex.value {
                switch Temp.currentUnit {
                case .fahrenheit:
                    var fahrenheit = Int(convertToFahrenheit(value: heat))
                    return " \(fahrenheit)°"
                case .celsius:
                    return " \(Int(heat))°"
                }
            } else if let chill = current.properties.windChill.value {
                switch Temp.currentUnit {
                case .fahrenheit:
                    var fahrenheit = Int(convertToFahrenheit(value: chill))
                    return " \(fahrenheit)°"
                case .celsius:
                    return " \(Int(chill))°"
                }
            } else {
                return "N/A"
            }
        } else {
            return "No data"
        }
    }

    // widget version
    func getCurrentHeatChill(useStub: Bool) -> String {
        if useStub {
            return " 79°"
        } else {
            if let current = WeatherLocations.currentConditions[PageControllerManager.currentPage] {
                if let heat = current.properties.heatIndex.value {
                    switch Temp.currentUnit {
                    case .fahrenheit:
                        var fahrenheit = Int(convertToFahrenheit(value: heat))
                        return " \(fahrenheit)°"
                    case .celsius:
                        return " \(Int(heat))°"
                    }
                } else if let chill = current.properties.windChill.value {
                    switch Temp.currentUnit {
                    case .fahrenheit:
                        var fahrenheit = Int(convertToFahrenheit(value: chill))
                        return " \(fahrenheit)°"
                    case .celsius:
                        return " \(Int(chill))°"
                    }
                } else {
                    return "N/A"
                }
            } else {
                return "No data"
            }
        }
    }

    func setHeatChillLabel() -> String {
        if let current = WeatherLocations.currentConditions[PageControllerManager.currentPage] {
            if let heat = current.properties.heatIndex.value {
                return "Heat Index"
            } else if let chill = current.properties.windChill.value {
                return "Wind Chill"
            } else {
                return "Heat Index"
            }
        } else {
            return "Heat Index"
        }
    }

    // widget version
    func setHeatChillLabel(useStub: Bool) -> String {
        if useStub {
            return "Heat Index"
        } else {
            if let current = WeatherLocations.currentConditions[PageControllerManager.currentPage] {
                if let heat = current.properties.heatIndex.value {
                    return "Heat Index"
                } else if let chill = current.properties.windChill.value {
                    return "Wind Chill"
                } else {
                    return "Heat Index"
                }
            } else {
                return "Heat Index"
            }
        }
    }


    func getCurrentConditionImage() -> UIImage? {
        if let isDay = isDayCurrently(), let iconString = getIcon() {
            return getImage(icon: iconString, isDaytime: isDay)
        } else {
            return nil
        }
    }

    // widget version
    func getCurrentConditionImage(useStub: Bool) -> UIImage? {
        if useStub {
            return UIImage(named: "partlycloudy")
        } else {
            if let isDay = isDayCurrently(), let iconString = getIcon() {
                return getImage(icon: iconString, isDaytime: isDay)
            } else {
                return nil
            }
        }
    }

    func hideAlertButton() -> Bool {
        if let alerts = WeatherLocations.alerts[PageControllerManager.currentPage] {
            if alerts.isEmpty {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }

    func getAlertButton() -> String {
        if let alerts = WeatherLocations.alerts[PageControllerManager.currentPage] {
            if alerts.isEmpty {
                return "none"
            } else {
                return "alert"
            }
        } else {
            return "none"
        }
    }

    // widget version
    func getAlertButton(useStub: Bool) -> String {
        if useStub {
            return "none"
        } else {
            if let alerts = WeatherLocations.alerts[PageControllerManager.currentPage] {
                if alerts.isEmpty {
                    return "none"
                } else {
                    return "alert"
                }
            } else {
                return "none"
            }
        }
    }

    // collection view

    func getForecastCount() -> Int {
        if let forecasts = WeatherLocations.forecasts[PageControllerManager.currentPage] {
            return forecasts.count
        } else {
            return 0
        }
    }

    func getForecastName(index: Int) -> String {
        if let forecasts = WeatherLocations.forecasts[PageControllerManager.currentPage] {
            return forecasts[index].name
        } else {
            return ""
        }
    }

    // widget version
    func getForecastName(index: Int, useStub: Bool) -> String {
        if useStub {
            return "Day Name"
        } else {
            if let forecasts = WeatherLocations.forecasts[PageControllerManager.currentPage] {
                return forecasts[index].name
            } else {
                return "-"
            }
        }
    }

    func getForecastTemp(index: Int) -> String {
        if let forecasts = WeatherLocations.forecasts[PageControllerManager.currentPage] {
            let temp = forecasts[index].temperature

            switch Temp.currentUnit {
            case .fahrenheit:
                return " \(temp)°"
            case .celsius:
                var celsius = convertToCelsius(value: Double(temp))
                return " \(celsius)°"
            }
        } else {
            return ""
        }
    }

    // widget version
    func getForecastTemp(index: Int, useStub: Bool) -> String {
        if useStub {
            return " 72°"
        } else {
            if let forecasts = WeatherLocations.forecasts[PageControllerManager.currentPage] {
                let temp = forecasts[index].temperature

                switch Temp.currentUnit {
                case .fahrenheit:
                    return " \(temp)°"
                case .celsius:
                    var celsius = convertToCelsius(value: Double(temp))
                    return " \(celsius)°"
                }
            } else {
                return ""
            }
        }
    }

    func getForecastDetail(index: Int) -> String {
        if let forecasts = WeatherLocations.forecasts[PageControllerManager.currentPage] {
            return forecasts[index].detailedForecast
        } else {
            return ""
        }
    }

    func getIconText(index: Int) -> String {
        if let forecasts = WeatherLocations.forecasts[PageControllerManager.currentPage] {
            let separated = forecasts[index].icon.components(separatedBy: "/")[6]
            let icon = separated.components(separatedBy: (","))[0].components(separatedBy: "?")[0]

            return icon
        } else {
            return ""
        }
    }

    func getForecastIcon(index: Int) -> UIImage? {
        if let forecasts = WeatherLocations.forecasts[PageControllerManager.currentPage] {
            var iconText = getIconText(index: index)
            return getImage(icon: iconText, isDaytime: forecasts[index].isDaytime)
        } else {
            return nil
        }
    }

    // widget version
    func getForecastIcon(index: Int, useStub: Bool) -> UIImage? {
        if useStub {
            return UIImage(named: "sunny")
        } else {
            if let forecasts = WeatherLocations.forecasts[PageControllerManager.currentPage] {
                var iconText = getIconText(index: index)
                return getImage(icon: iconText, isDaytime: forecasts[index].isDaytime)
            } else {
                return nil
            }
        }
    }

    func getIcon() -> String? {
        if let weatherIcon = WeatherLocations.currentConditions[PageControllerManager.currentPage]?.properties.icon {

            let separated = weatherIcon.components(separatedBy: "/")[6]

            let icon = separated.components(separatedBy: (","))[0].components(separatedBy: "?")[0]
            return icon
        } else {
            return nil
        }
    }

    func getForecastText(index: Int) -> String {
        var icon = getIconText(index: index)

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
        case Icons.dust.rawValue:
            return "Dust"
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

    // widget version
    func getForecastText(index: Int, useStub: Bool) -> String {
        if useStub {
            return "Sunny"
        } else {
            var icon = getIconText(index: index)

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
            case Icons.dust.rawValue:
                return "Dust"
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
            case Icons.smoke.rawValue, Icons.dust.rawValue:
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
            case Icons.smoke.rawValue, Icons.dust.rawValue:
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
}
