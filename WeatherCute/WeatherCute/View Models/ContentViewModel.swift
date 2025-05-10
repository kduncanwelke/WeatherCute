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
    
    var unit: TemperatureUnit = .fahrenheit

    weak var delegate: RetryDelegate?

    func getLocationsCount() -> Int {
        return WeatherLocations.locations.count
    }
    
    func setSearchParameters(for index: Int) {
        print("set search")
        var location = WeatherLocations.locations[index]
        
        LocationSearch.latitude = location.latitude
        LocationSearch.longitude = location.longitude

        ForecastSearch.gridX = Int(location.xCoord ?? 0)
        ForecastSearch.gridY = Int(location.yCoord ?? 0)
        ForecastSearch.station = location.station ?? ""
        ForecastSearch.observationStation = location.observationStation ?? ""
    }

    func getWeatherData(index: Int) async throws {
        do {
            let response = try await Networker<Current>.fetch()
        
            let name = WeatherLocations.locations[index].name
            WeatherLocations.currentConditions[name] = response
        } catch {
            // handle error
        }
    }

    func getForecastData(index: Int, retried: Bool) async throws {
        do {
            let response = try await Networker<Forecast>.fetch()
            
            let data = response.properties.periods
            var forecasts: [ForecastData] = []

            for forecast in data {
                forecasts.append(forecast)
            }

            let name = WeatherLocations.locations[index].name
            WeatherLocations.forecasts[name] = forecasts
            
            if retried {
                delegate?.showActivityIndicator(display: false)
            }
        } catch {
            // handle error
            if retried == false {
                if error as? Errors == Errors.unexpectedProblem {
                    print("retry")
                    delegate?.showActivityIndicator(display: true)
                    // retry 500 error request; per NOAA ServiceNow support 500 errors can typically be fixed with a second request (use brief wait to avoid rate limit)
                    try await Task.sleep(nanoseconds: 5_000_000_000)
                    try await getForecastData(index: index, retried: true)
                }
            }
        }
    }

    func getAlerts(index: Int) async throws {
        do {
            let response = try await Networker<Alert>.fetch()
            print("fetch alerts")
            
            let data = response.features
                var alertList: [AlertInfo] = []
                
            for alert in data {
            alertList.append(alert)
            }
            
            let name = WeatherLocations.locations[index].name
            WeatherLocations.alerts[name] = alertList
        } catch {
            // handle error
        }
    }

    func isLoaded(index: Int) -> Bool {
        let name = WeatherLocations.locations[index].name
        
        if WeatherLocations.currentConditions[name] != nil && !(WeatherLocations.forecasts[name]?.isEmpty ?? true) && WeatherLocations.alerts[name] != nil  {
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

    func isDayCurrently(index: Int) -> Bool?  {
        let name = WeatherLocations.locations[index].name
        
        if let weatherIcon = WeatherLocations.currentConditions[name]?.properties.icon {
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

    func getLocationName(index: Int) -> String {
        return WeatherLocations.locations[index].name
    }

    // widget version
    func getLocationName(index: Int, useStub: Bool) -> String {
        if useStub {
            return "Your Location"
        } else {
            return WeatherLocations.locations[index].name
        }
    }

    func getObservationName(index: Int) -> String {
        return "Current conditions from \(WeatherLocations.locations[index].observationStation ?? "")"
    }

    func getCurrentTemp(index: Int) -> String {
        let name = WeatherLocations.locations[index].name
        
        if let current = WeatherLocations.currentConditions[name] {
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
    func getCurrentTemp(index: Int, useStub: Bool) -> String {
        if useStub {
            return " 75°"
        } else {
            let name = WeatherLocations.locations[index].name
            if let current = WeatherLocations.currentConditions[name] {
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

    func getCurrentDescription(index: Int) -> String {
        let name = WeatherLocations.locations[index].name
        if let current = WeatherLocations.currentConditions[name]  {
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
    func getCurrentDescription(index: Int, useStub: Bool) -> String {
        if useStub {
            return "Partly Cloudy"
        } else {
            let name = WeatherLocations.locations[index].name
            if let current = WeatherLocations.currentConditions[name] {
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

    func getCurrentHumidity(index: Int) -> String {
        let name = WeatherLocations.locations[index].name
        if let current = WeatherLocations.currentConditions[name] {
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
    func getCurrentHumidity(index: Int, useStub: Bool) -> String {
        if useStub {
            return "50%"
        } else {
            let name = WeatherLocations.locations[index].name
            if let current = WeatherLocations.currentConditions[name] {
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

    func getCurrentDewpoint(index: Int) -> String {
        let name = WeatherLocations.locations[index].name
        if let current = WeatherLocations.currentConditions[name] {
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
    func getCurrentDewpoint(index: Int, useStub: Bool) -> String {
        if useStub {
            return " 60°"
        } else {
            let name = WeatherLocations.locations[index].name
            if let current = WeatherLocations.currentConditions[name] {
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

    func getCurrentHeatChill(index: Int) -> String {
        let name = WeatherLocations.locations[index].name
        if let current = WeatherLocations.currentConditions[name] {
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
    func getCurrentHeatChill(index: Int, useStub: Bool) -> String {
        if useStub {
            return " 79°"
        } else {
            let name = WeatherLocations.locations[index].name
            if let current = WeatherLocations.currentConditions[name] {
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

    func setHeatChillLabel(index: Int) -> String {
        let name = WeatherLocations.locations[index].name
        if let current = WeatherLocations.currentConditions[name] {
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
    func setHeatChillLabel(index: Int, useStub: Bool) -> String {
        if useStub {
            return "Heat Index"
        } else {
            let name = WeatherLocations.locations[index].name
            if let current = WeatherLocations.currentConditions[name] {
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


    func getCurrentConditionImage(index: Int) -> UIImage? {
        if let isDay = isDayCurrently(index: index), let iconString = getIcon(index: index) {
            return getImage(icon: iconString, isDaytime: isDay)
        } else {
            return nil
        }
    }

    // widget version
    func getCurrentConditionImage(index: Int, useStub: Bool) -> UIImage? {
        if useStub {
            return UIImage(named: "partlycloudy")
        } else {
            if let isDay = isDayCurrently(index: index), let iconString = getIcon(index: index) {
                return getImage(icon: iconString, isDaytime: isDay)
            } else {
                return nil
            }
        }
    }

    func hideAlertButton(index: Int) -> Bool {
        let name = WeatherLocations.locations[index].name
        if let alerts = WeatherLocations.alerts[name] {
            if alerts.isEmpty {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }

    func getAlertButton(index: Int) -> String {
        let name = WeatherLocations.locations[index].name
        if let alerts = WeatherLocations.alerts[name] {
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
    func getAlertButton(index: Int, useStub: Bool) -> String {
        if useStub {
            return "none"
        } else {
            let name = WeatherLocations.locations[index].name
            if let alerts = WeatherLocations.alerts[name] {
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

    func getForecastCount(index: Int) -> Int {
        let name = WeatherLocations.locations[index].name
        if let forecasts = WeatherLocations.forecasts[name] {
            return forecasts.count
        } else {
            return 0
        }
    }
    
    func getForecastName(index: Int) -> String {
        let name = WeatherLocations.locations[index].name
        if let forecasts = WeatherLocations.forecasts[name] {
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
            let name = WeatherLocations.locations[index].name
            if let forecasts = WeatherLocations.forecasts[name] {
                return forecasts[index].name
            } else {
                return "-"
            }
        }
    }

    func getForecastTemp(index: Int) -> String {
        let name = WeatherLocations.locations[index].name
        if let forecasts = WeatherLocations.forecasts[name] {
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
            let name = WeatherLocations.locations[index].name
            if let forecasts = WeatherLocations.forecasts[name] {
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
        let name = WeatherLocations.locations[index].name
        if let forecasts = WeatherLocations.forecasts[name] {
            return forecasts[index].detailedForecast
        } else {
            return ""
        }
    }

    func getIconText(index: Int) -> String {
        let name = WeatherLocations.locations[index].name
        if let forecasts = WeatherLocations.forecasts[name] {
            let separated = forecasts[index].icon.components(separatedBy: "/")[6]
            let icon = separated.components(separatedBy: (","))[0].components(separatedBy: "?")[0]
            
            return icon
        } else {
            return ""
        }
    }

    func getForecastIcon(index: Int) -> UIImage? {
        let name = WeatherLocations.locations[index].name
        if let forecasts = WeatherLocations.forecasts[name] {
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
            let name = WeatherLocations.locations[index].name
            if let forecasts = WeatherLocations.forecasts[name] {
                var iconText = getIconText(index: index)
                return getImage(icon: iconText, isDaytime: forecasts[index].isDaytime)
            } else {
                return nil
            }
        }
    }

    func getIcon(index: Int) -> String? {
        let name = WeatherLocations.locations[index].name
        if let weatherIcon = WeatherLocations.currentConditions[name]?.properties.icon {

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
