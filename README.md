# WeatherCute
U.S. Weather - but cute!

This app uses weather data from the [National Weather Service API](https://www.weather.gov/documentation/services-web-api) to track weather and forecasts for a user's selected locations. WeatherCute combines a user-friendly interface and friendly art with current condition and forecast data from the National Weather Service to provide an easy and fun way for users to get their U.S. weather. Features include current conditions, forecasts for both day and night, toggling between Fahrenheit and Celsius measurements, easy addition and deletion of locations, current alerts, and more.

![Screenshot of the app WeatherCute](https://kduncanwelkecom.ipage.com/WeatherCute%20Preview.png)

## Description
Track weather and forecasts for your favorite U.S. locations! 

With a user-friendly interface, adorable art, and weather data provided by the National Weather Service API, WeatherCute provides all your weather needs in an easy to digest, fun format.

Features include:
* Current condition information
* Forecast data (both day and night)
* Easy addition and deletion of locations
* Cute and simple art for at-a-glance understanding
* Location selection from either a map tap or search
* Observation station selection for current condition reports
* A red button displayed when alerts are active for a location
* Detailed alert info direct from the NWS, including advised steps
* Easy toggling between Fahrenheit and Celsius measurements

## Features
The app accesses the NWS API and retrieves and parses JSON (using Codable) to provide current weather condition and forecast information for locations a user has selected. Locations are displayed in a page view controller, and can be swiped through readily. A user adds locations by hitting the plus button in the upper right - this directs to a view with a map of the United States and a search bar. Locations can be selected either by map tap, or searching by city or zipcode. Once confirmed, a selected location is saved in Core Data.

The main view for any selected weather location features an area for current conditions and forecast data. Three API calls are made for each location - one for current conditions, one for forecast data, and lastly one for current alerts. Once all of this data has loaded, a refresh button is enabled. This allows the user to refresh the data as desired.

Current conditions show basic information such as temperature and a brief description, along with a user-friendly image created for the app. Forecast data is displayed in a collection view. Long pressing on a forecast image will bring up a detailed text view. If alerts are present, a red ! button is displayed next to the current temperature. This leads to an alert area which provides details and suggested steps, as per the NWS.

The current condition reporting location is by default the first item returned by the API. The user can choose a preferred reporting location if they wish, however, by selecting the 'change?' button. A control at the top of the view allows toggling between fahrenheit and celsius measurements.

The app now includes a widget capability, using WidgetKit and SwiftUI to display various sizes of widget, which show weather for the user's first selected weather location. Different sizes of widget display differing degrees of information, and all are set to update on an hourly basis.

## Art
Unique art for every weather condition specified by the NWS API (and for both day and nighttime conditions) is included as an integral part of this app, to allow at-a-glance understanding. This art was created by myself (the developer) and belongs to no one else. The art displayed is set based off the icons returned by the API, however, these icons themselves are not used within the app.

## Support
If you experience trouble using the app, have any questions, or simply want to contact me, you can contact me via email at kduncanwelke@gmail.com. I will be happy to discuss this project.

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/S6S03G1HT)
