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

    // helpers

    func convertToFahrenheit(value: Double) -> Int {
        let result = (value * 9/5) + 32
        return Int(result)
    }

    func convertToCelsius(value: Double) -> Int {
        let result = (value - 32) / 1.8
        return Int(result)
    }

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
        return WeatherLocations.locations[PageControllerManager.currentPage].name ?? ""
    }

    func getObservationName() -> String {
        return "Current conditions from \(WeatherLocations.locations[PageControllerManager.currentPage].observation ?? "")"
    }

    func getCurrentTemp() -> String {
        if let current = WeatherLocations.currentConditions[PageControllerManager.currentPage] {
            let temp = current.properties.temperature.value ?? 0

            switch Temp.currentUnit {
            case .fahrenheit:
                return " \(temp)°"
            case .celsius:
                var celsius = convertToCelsius(value: temp)
                return " \(celsius)°"
            }
        } else {
            return "No data"
        }
    }

    func getCurrentDescription() -> String {
        if let current = WeatherLocations.currentConditions[PageControllerManager.currentPage] {
            return current.properties.textDescription
        } else {
            return "No current reporting"
        }
    }

    func getCurrentHumidity() -> String {
        if let current = WeatherLocations.currentConditions[PageControllerManager.currentPage] {
            let humidity = current.properties.relativeHumidity.value
            return "\(humidity)%"
        } else {
            return "No data"
        }
    }

    func getCurrentDewpoint() -> String {
        if let current = WeatherLocations.currentConditions[PageControllerManager.currentPage] {
            let dew = current.properties.dewpoint.value ?? 0

            switch Temp.currentUnit {
            case .fahrenheit:
                return "\(dew)°"
            case .celsius:
                var celsius = convertToCelsius(value: dew)
                return "\(celsius)°"
            }
        } else {
            return "No data"
        }
    }

    func getCurrentHeatChill() -> String {
        if let current = WeatherLocations.currentConditions[PageControllerManager.currentPage] {
            if let heat = current.properties.heatIndex.value {
                switch Temp.currentUnit {
                case .fahrenheit:
                    return "\(heat)°"
                case .celsius:
                    var celsius = convertToCelsius(value: heat)
                    return "\(celsius)°"
                }
            } else if let chill = current.properties.windChill.value {
                switch Temp.currentUnit {
                case .fahrenheit:
                    return "\(chill)°"
                case .celsius:
                    var celsius = convertToCelsius(value: chill)
                    return "\(celsius)°"
                }
            } else {
                return "N/A"
            }
        } else {
            return "No data"
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

    func getCurrentConditionImage() -> UIImage? {
        if let isDay = isDayCurrently(), let iconString = getIcon() {
            return getImage(icon: iconString, isDaytime: isDay)
        } else {
            return nil
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
