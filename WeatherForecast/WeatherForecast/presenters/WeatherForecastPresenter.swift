//
//  WeatherForecastPresenter.swift
//  WeatherForecast
//
//  Created by Damien Bivaud on 10/09/2019.
//  Copyright © 2019 damz. All rights reserved.
//

import Foundation
import Network

enum ForecastDescription
{
    case sunny
    case cloudy
    case partialcloud
    case dayrain
    case rain
}

struct HourlyForecast
{
    var date : Date?
    var description : ForecastDescription?
    var temperature : Double?
    var rain : Int?
    var windForce : Double?
    var windDirection : Int?
}

// Business Object to show daily forecast
struct DailyForecastData
{
    var date : Date?
    var location : String?
    var description : ForecastDescription?
    var temperature : Double?
    var rain : Int?
    var hourlyForecasts : [HourlyForecast]?
}

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
//                    self.weatherForecastView?.setForecasts(forecasts)
                    self.dailyForeCasts = self._extractDailyForecastData(data: self.weatherForecastData.hourlyWeatherForecasts)
                    self.weatherForecastView?.setDailyForecasts(self.dailyForeCasts!)
                }
                else
                {
                    // No data has been received, could be a timeout, could be no data at all
                    // try to show what's in the save anyway (possibly loaded from disk)
                    if self.weatherForecastData.hourlyWeatherForecasts.isEmpty == false
                    {
                        self.dailyForeCasts = self._extractDailyForecastData(data: self.weatherForecastData.hourlyWeatherForecasts)
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
                self.dailyForeCasts = self._extractDailyForecastData(data: self.weatherForecastData.hourlyWeatherForecasts)
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
    
    private func _extractDailyForecastData(data: [HourlyWeatherForecast]) -> [DailyForecastData]?
    {
        var currentForeCast : HourlyWeatherForecast?
        var gatheredForecasts : [HourlyWeatherForecast]?
        var dailyForecasts : [DailyForecastData]?
        
        // sort forecasts by date
        let forecasts = data.sorted(by: { $0.date < $1.date })
        for forecast in forecasts
        {
            if currentForeCast != nil
            {
                if Calendar.current.isDate(currentForeCast!.date, inSameDayAs:forecast.date)
                {
                    gatheredForecasts?.append(forecast)
                    currentForeCast = forecast
                    continue
                }
                else
                {
                    if let dailyForecast = _getDailyForecastDataFromHourlyForecasts(forecasts: gatheredForecasts)
                    {
                        if dailyForecasts == nil
                        {
                            dailyForecasts = [DailyForecastData]()
                        }
                        dailyForecasts?.append(dailyForecast)
                    }
                }
            }
            currentForeCast = forecast
            gatheredForecasts = [HourlyWeatherForecast]()
            gatheredForecasts?.append(currentForeCast!)
        }
        return dailyForecasts
    }
    
    private func _getDailyForecastDataFromHourlyForecasts(forecasts: [HourlyWeatherForecast]?) -> DailyForecastData?
    {
        if let hourlyForecasts = forecasts, hourlyForecasts.isEmpty == false
        {
            var dailyForecast = DailyForecastData()
            dailyForecast.date = hourlyForecasts[0].date
            dailyForecast.hourlyForecasts = [HourlyForecast]()
            
            // extract infos
            var nebulosity : Int = 0
            var rain : Int = 0
            var temperature : Double = 0
            var nb : Int = 0
            for hourlyForeCast in hourlyForecasts
            {
                var hourlyForecastData = HourlyForecast()
                hourlyForecastData.date = hourlyForeCast.date
                hourlyForecastData.rain = hourlyForeCast.rain
                hourlyForecastData.description = _getDescriptionFrom(rain: hourlyForeCast.rain, nebulosity: hourlyForeCast.nebulosity)
                hourlyForecastData.temperature = hourlyForeCast.temperature
                hourlyForecastData.windForce = hourlyForeCast.wind_force
                hourlyForecastData.windDirection = hourlyForeCast.wind_direction
                
                if let fRain = hourlyForeCast.rain, let fNebulosity = hourlyForeCast.nebulosity, let fTemperature = hourlyForeCast.temperature
                {
                    rain += fRain
                    nebulosity += fNebulosity
                    temperature += fTemperature
                    nb += 1
                }
                dailyForecast.hourlyForecasts?.append(hourlyForecastData)
            }
            dailyForecast.description = _getDescriptionFrom(rain: rain / nb, nebulosity: nebulosity / nb)
            dailyForecast.rain = rain / nb
            dailyForecast.temperature = temperature / Double(nb)
            return dailyForecast
        }
        return nil
    }
    
    private func _getDescriptionFrom(rain: Int?, nebulosity: Int?) -> ForecastDescription
    {
        if let vRain = rain, let vNebulosity = nebulosity
        {
            if (vRain == 0)
            {
                if vNebulosity == 0
                {
                    return .sunny
                }
                else if vNebulosity < 50
                {
                    return .partialcloud
                }
                else
                {
                    return .cloudy
                }
            }
            else
            {
                if vNebulosity < 50
                {
                    return .dayrain
                }
                else
                {
                    return .rain
                }
            }
        }
        return .sunny
    }
}
