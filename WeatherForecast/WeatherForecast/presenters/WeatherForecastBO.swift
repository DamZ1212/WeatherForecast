//
//  WeatherForecastBusinessObjects.swift
//  WeatherForecast
//
//  Created by Damien Bivaud on 11/09/2019.
//  Copyright © 2019 damz. All rights reserved.
//

import Foundation
import UIKit

/* Defines how to describe the current forecast with an icon */
class ForecastDescription
{
    enum ForecastDescriptionItem : String
    {
        case sunny = "day_clear"
        case cloudy = "cloudy"
        case partialcloud = "day_partial_cloud"
        case dayrain = "day_rain"
        case rain = "rain"
    }
    
    let item : ForecastDescriptionItem
    
    init(item: ForecastDescriptionItem)
    {
        self.item = item
    }
    
    func getImage() -> UIImage
    {
        var weatherIcon: UIImage {
            return UIImage(named: item.rawValue)!
        }
        return weatherIcon
    }
}

/* Business Object representing an hourly forecast to be shown in the detailview */
struct HourlyForecast
{
    var date : Date?
    var description : ForecastDescription?
    var temperature : Double?
    var rain : Int?
    var windForce : Double?
    var windDirection : Int?
    var pressure : Int?
    var humidity : Double?
}

/* Business Object representing a daily forecast with average values and an array of hourly forecasts */
struct DailyForecastData
{
    var date : Date?
    var location : String?
    var description : ForecastDescription?
    var temperature : Double?
    var rain : Int?
    var pressure : Int?
    var windForce : Double?
    var windDirection : Int?
    var humidity : Double?
    var hourlyForecasts : [HourlyForecast]?
}

/* Business Objects utility functions */
class WeatherForecastBO
{
    // Retrieves an array of hourly weather forecasts according to a dailyforecast */
    static func getDailyForecastData(data: [HourlyWeatherForecast]) -> [DailyForecastData]?
    {
        var currentForeCast : HourlyWeatherForecast?
        var gatheredForecasts : [HourlyWeatherForecast]?
        var dailyForecasts : [DailyForecastData]?
        
        // sort forecasts by date
        let forecasts = data.sorted(by: { $0.date < $1.date })
        for forecast in forecasts
        {
            // previous forecast
            if currentForeCast != nil
            {
                // is current forecast and previous forecat of the same day ?
                if Calendar.current.isDate(currentForeCast!.date, inSameDayAs:forecast.date)
                {
                    // If so, append to the current array we're filling
                    gatheredForecasts?.append(forecast)
                    // previous forecast will be the current one
                    currentForeCast = forecast
                    continue
                }
                else
                {
                    // Not the same day, we're done pushing to the current array
                    // Try to create a daily forecast out of the hourly forecasts we gathered
                    if let dailyForecast = WeatherForecastBO.getDailyForecastDataFromHourlyForecasts(forecasts: gatheredForecasts)
                    {
                        // If daily forecast array doesnt exist, create it
                        if dailyForecasts == nil
                        {
                            dailyForecasts = [DailyForecastData]()
                        }
                        // Append daily forecast created
                        dailyForecasts?.append(dailyForecast)
                    }
                }
            }
            // pointer to last forecast
            currentForeCast = forecast
            // create new array of hourly forecasts
            gatheredForecasts = [HourlyWeatherForecast]()
            // Append this one
            gatheredForecasts?.append(currentForeCast!)
        }
        return dailyForecasts
    }
    
    /* Creates a daily forecast according to an array of hourly forecasts of the same day */
    static func getDailyForecastDataFromHourlyForecasts(forecasts: [HourlyWeatherForecast]?) -> DailyForecastData?
    {
        // Check if array not empty
        if let hourlyForecasts = forecasts, hourlyForecasts.isEmpty == false
        {
            var dailyForecast = DailyForecastData()
            // Daily forecast date will be the one of the first hourly forecast
            // We only care about the calendar day, time doesnt matter
            dailyForecast.date = hourlyForecasts[0].date
            dailyForecast.hourlyForecasts = [HourlyForecast]()
            
            // extract infos
            var nebulosity : Int = 0
            var rain : Int = 0
            var temperature : Double = 0
            var humidity : Double = 0
            var pressure : Int = 0
            var windDir : Int = 0
            var windForce : Double = 0
            var count : Int = 0
            
            // hourlyForecasts not empty, at least one forecast in the collection
            for hourlyForeCast in hourlyForecasts
            {
                // Creates an hourlyForecast BO
                var hourlyForecastData = HourlyForecast()
                hourlyForecastData.date = hourlyForeCast.date
                hourlyForecastData.rain = hourlyForeCast.rain
                hourlyForecastData.description = WeatherForecastBO.getForecastDescription(rain: hourlyForeCast.rain, nebulosity: hourlyForeCast.nebulosity)
                hourlyForecastData.temperature = hourlyForeCast.temperature
                hourlyForecastData.windForce = hourlyForeCast.wind_force
                hourlyForecastData.windDirection = hourlyForeCast.wind_direction
                hourlyForecastData.pressure = hourlyForeCast.pressure
                
                // Additionning all properties we need to calculate average values
                if let fRain = hourlyForeCast.rain, let fNebulosity = hourlyForeCast.nebulosity, let fTemperature = hourlyForeCast.temperature, let fPressure = hourlyForeCast.pressure, let fHumidity = hourlyForeCast.humidity, let fWindForce = hourlyForeCast.wind_force, let fWindDir = hourlyForeCast.wind_direction
                {
                    rain += fRain
                    nebulosity += fNebulosity
                    temperature += fTemperature
                    humidity += fHumidity
                    pressure += fPressure
                    windDir += fWindDir
                    windForce += fWindForce
                }
                count += 1
                dailyForecast.hourlyForecasts?.append(hourlyForecastData)
            }
            
            // Calculating average values
            let averageRain = rain / count
            let averageNebulosity = nebulosity / count
            let averageTemperature = temperature / Double(count)
            let averagePressure = pressure / count
            let averageHumidity = humidity / Double(count)
            let averageWindforce = windForce / Double(count)
            let averageWindDirection = windDir / count
            
            // Pushing values to daily forecast BO
            dailyForecast.description = WeatherForecastBO.getForecastDescription(rain: averageRain, nebulosity: averageNebulosity)
            dailyForecast.rain = averageRain
            dailyForecast.temperature = averageTemperature
            dailyForecast.pressure = averagePressure
            dailyForecast.humidity = averageHumidity
            dailyForecast.windForce = averageWindforce
            dailyForecast.windDirection = averageWindDirection
            
            return dailyForecast
        }
        return nil
    }
    
    // Creates a forecast description according to amount of rain and nebulosity
    // Threshold values make no sense, we might need to adjust them if some icons just show too often
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
