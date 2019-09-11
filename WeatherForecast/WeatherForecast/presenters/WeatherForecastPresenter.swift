//
//  WeatherForecastPresenter.swift
//  WeatherForecast
//
//  Created by Damien Bivaud on 10/09/2019.
//  Copyright © 2019 damz. All rights reserved.
//

import Foundation
import Network
import os.log

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
                (hourlyForecasts: [HourlyWeatherForecast]?, error: WeatherForeCastServiceError?) in
                // Error !
                if error != nil
                {
                    os_log("Service returned an error", log: OSLog.default, type: .debug)
                    // Try to show some data anyway
                    self.createWeatherForecastBOAndFeedView()
                    return
                }
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
                    self.createWeatherForecastBOAndFeedView()
                }
                else
                {
                    self.createWeatherForecastBOAndFeedView()
                }
            }
        }
        // NO internet, try to show saved data
        else
        {
            self.createWeatherForecastBOAndFeedView()
        }
    }
    
    func createWeatherForecastBOAndFeedView(){
        
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
