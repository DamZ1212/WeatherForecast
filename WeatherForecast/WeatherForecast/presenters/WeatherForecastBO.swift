//
//  WeatherForecastBusinessObjects.swift
//  WeatherForecast
//
//  Created by Damien Bivaud on 11/09/2019.
//  Copyright © 2019 damz. All rights reserved.
//

import Foundation
import UIKit

class ForecastDescription
{
    enum ForecastDescriptionItem
    {
        case sunny
        case cloudy
        case partialcloud
        case dayrain
        case rain
    }
    
    let item : ForecastDescriptionItem
    
    init(item: ForecastDescriptionItem)
    {
        self.item = item
    }
    
    func getImage() -> UIImage
    {
        var weatherIcon: UIImage {
            switch self.item {
            case .sunny:
                return UIImage(named: "day_clear")!
            case .cloudy:
                return UIImage(named: "cloudy")!
            case .partialcloud:
                return UIImage(named: "day_partial_cloud.png")!
            case .dayrain:
                return UIImage(named: "day_rain.png")!
            case .rain:
                return UIImage(named: "rain.png")!
            }
        }
        return weatherIcon
    }
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

class WeatherForecastBO
{
    static func getDailyForecastData(data: [HourlyWeatherForecast]) -> [DailyForecastData]?
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
                    if let dailyForecast = WeatherForecastBO.getDailyForecastDataFromHourlyForecasts(forecasts: gatheredForecasts)
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
    
    static func getDailyForecastDataFromHourlyForecasts(forecasts: [HourlyWeatherForecast]?) -> DailyForecastData?
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
                hourlyForecastData.description = WeatherForecastBO.getForecastDescription(rain: hourlyForeCast.rain, nebulosity: hourlyForeCast.nebulosity)
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
            let averageRain = rain / nb
            let averageNebulosity = nebulosity / nb
            let averageTemperaure = temperature / Double(nb)
            dailyForecast.description = WeatherForecastBO.getForecastDescription(rain: averageRain, nebulosity: averageNebulosity)
            dailyForecast.rain = averageRain
            dailyForecast.temperature = averageTemperaure
            return dailyForecast
        }
        return nil
    }
    
    static func getForecastDescription(rain: Int?, nebulosity: Int?) -> ForecastDescription
    {
        if let vRain = rain, let vNebulosity = nebulosity
        {
            if (vRain == 0)
            {
                if vNebulosity == 0
                {
                    return ForecastDescription(item:.sunny)
                }
                else if vNebulosity < 50
                {
                    return ForecastDescription(item:.partialcloud)
                }
                else
                {
                    return ForecastDescription(item:.cloudy)
                }
            }
            else
            {
                if vNebulosity < 50
                {
                    return ForecastDescription(item:.dayrain)
                }
                else
                {
                    return ForecastDescription(item:.rain)
                }
            }
        }
        return ForecastDescription(item:.sunny)
    }
}
