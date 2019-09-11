//
//  WeatherForecastPresenter.swift
//  WeatherForecast
//
//  Created by Damien Bivaud on 10/09/2019.
//  Copyright © 2019 damz. All rights reserved.
//

import Foundation
import Network

// View protocol
protocol WeatherForecastView
{
    func setDailyForecasts(_ forecasts: [DailyForecastData]?)
}

/* Main presenter
 Create the service that communicate with data suppliers
 Create the model to store the data
 Communicate with the link view to push BO to show
 */
class WeatherForecastPresenter
{
    let weatherForecastService : WeatherForecastRequestService
    let weatherForecastData : WeatherForecastData
    
    var weatherForecastView : WeatherForecastView?
    var dailyForeCasts : [DailyForecastData]?
    
    init() {
        self.weatherForecastService = WeatherForecastRequestService()
        self.weatherForecastData = WeatherForecastData()
        // At creation, load from disk
        self.weatherForecastData.loadFromDisk()
    }
    
    func attachView(_ view: WeatherForecastView){
        weatherForecastView = view
    }
    
    func detachView() {
        weatherForecastView = nil
    }
    
    // Try to retrieve forecasts according to a GPS (longitude, latitute) location
    func getDailyWeatherForecastsForLocation(location: String){
        
        // Check if internet connexion is available
        if let path = Reachability.instance.currentPath, path.status == .satisfied
        {
            // if so, ask the weather forecast service to give us a list of forecasts
            weatherForecastService.getWeatherForecastsForLocation(location: location)
            {
                (hourlyForecasts: [HourlyWeatherForecast]?) in
                // We got some forecasts
                if let forecasts = hourlyForecasts, forecasts.isEmpty == false
                {
                    // Cleanup the previously stored data
                    self.weatherForecastData.cleanUp()
                    // Add each forecast to the model
                    for forecast in forecasts
                    {
                        self.weatherForecastData.addHourlyForecast(forecast: forecast)
                    }
                    // Save the model on disk
                    self.weatherForecastData.saveOnDisk()
                    // Create the daily forecast BO to be used by the views
                    self.dailyForeCasts = WeatherForecastBO.getDailyForecastData(data: self.weatherForecastData.hourlyWeatherForecasts)
                    // Ask the view to show the actual data
                    self.weatherForecastView?.setDailyForecasts(self.dailyForeCasts!)
                }
                else
                {
                    // No data has been received, could be a timeout, could be no data at all
                    // Fallbacking on the local save if available
                    if self.weatherForecastData.hourlyWeatherForecasts.isEmpty == false
                    {
                        // Local save is available
                        self.dailyForeCasts = WeatherForecastBO.getDailyForecastData(data: self.weatherForecastData.hourlyWeatherForecasts)
                        self.weatherForecastView?.setDailyForecasts(self.dailyForeCasts!)
                    }
                    // No data in the save
                    else
                    {
                        self.weatherForecastView?.setDailyForecasts(nil)
                    }
                }
            }
        }
            // NO internet, try to show saved data
        else
        {
            if self.weatherForecastData.hourlyWeatherForecasts.isEmpty == false
            {
                self.dailyForeCasts = WeatherForecastBO.getDailyForecastData(data: self.weatherForecastData.hourlyWeatherForecasts)
                self.weatherForecastView?.setDailyForecasts(self.dailyForeCasts!)
            }
            else
            {
                // No data to show at all...
                self.weatherForecastView?.setDailyForecasts(nil)
            }
        }
    }
}
