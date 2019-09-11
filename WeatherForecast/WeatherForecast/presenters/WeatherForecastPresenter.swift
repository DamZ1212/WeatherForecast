//
//  WeatherForecastPresenter.swift
//  WeatherForecast
//
//  Created by Damien Bivaud on 10/09/2019.
//  Copyright © 2019 damz. All rights reserved.
//

import Foundation
import Network

protocol WeatherForecastView
{
    func setDailyForecasts(_ forecasts: [DailyForecastData]?)
}

class WeatherForecastPresenter
{
    let weatherForecastService : WeatherForecastRequestService
    let weatherForecastData : WeatherForecastData
    
    var weatherForecastView : WeatherForecastView?
    var dailyForeCasts : [DailyForecastData]?
    
    init() {
        self.weatherForecastService = WeatherForecastRequestService()
        self.weatherForecastData = WeatherForecastData()
        self.weatherForecastData.loadFromDisk()
    }
    
    func attachView(_ view: WeatherForecastView){
        weatherForecastView = view
    }
    
    func detachView() {
        weatherForecastView = nil
    }
    
    // Replace with promises help with the flow
    func getDailyWeatherForecastsForLocation(location: String){
        
        // If connexion not available, ask for the model to load data from disk
        // return an array of forecasts.
        // can return an empty array, if so show alert to the user
        if let path = Reachability.instance.currentPath, path.status == .satisfied
        {
            weatherForecastService.getWeatherForecastsForLocation(location: location)
            {
                (hourlyForecasts: [HourlyWeatherForecast]?) in
                if let forecasts = hourlyForecasts, forecasts.isEmpty == false
                {
                    self.weatherForecastData.cleanUp()
                    for forecast in forecasts
                    {
                        self.weatherForecastData.addHourlyForecast(forecast: forecast)
                    }
                    self.weatherForecastData.saveOnDisk()
                    self.dailyForeCasts = WeatherForecastBO.getDailyForecastData(data: self.weatherForecastData.hourlyWeatherForecasts)
                    self.weatherForecastView?.setDailyForecasts(self.dailyForeCasts!)
                }
                else
                {
                    // No data has been received, could be a timeout, could be no data at all
                    // try to show what's in the save anyway (possibly loaded from disk)
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
    
    func getWeatherForecastForDay(date: Date)
    {
    }
}
