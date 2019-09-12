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
import PromiseKit

// View protocol
protocol WeatherForecastView
{
    func setDailyForecasts(_ forecasts: [DailyForecastData]?)
}

/* Main presenter
 Create the service that communicate with data suppliers
 Create the model to store the data
 Ask the view to show computed business objects
 */
class WeatherForecastPresenter
{
    let weatherForecastService : WeatherForecastRequestService // service
    let weatherForecastData : WeatherForecastData // model
    
    var weatherForecastView : WeatherForecastView? // view
    var dailyForeCasts : [DailyForecastData]? // stored returned forecasts from service
    
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
            self.weatherForecastService.getWeatherForecastsForLocation(location: location)
            .done{ forecasts in
                if let hourlyForecasts = forecasts, hourlyForecasts.isEmpty == false
                {
                    // Cleanup the previously stored data
                    self.weatherForecastData.cleanUp()
                    // Add each forecast to the model
                    for forecast in hourlyForecasts
                    {
                        self.weatherForecastData.addHourlyForecast(forecast: forecast)
                    }
                    // Save the model on disk
                    self.weatherForecastData.saveOnDisk()
                    self.createWeatherForecastsBOAndFeedView()
                }
            }
            .catch
            {
                error in
                // Try to show some data anyway
                os_log("Weather service triggered an error, attempting to parse local data", log: OSLog.default, type: .error)
                
                self.createWeatherForecastsBOAndFeedView()
            }
        }
        else
        {
            self.createWeatherForecastsBOAndFeedView()
        }
    }
    
    // Create daily forecast business objects, and feed the view with them
    func createWeatherForecastsBOAndFeedView(){
        
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
