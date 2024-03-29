//
//  WeatherForecastRequestService.swift
//  WeatherForecast
//
//  Created by Damien Bivaud on 10/09/2019.
//  Copyright © 2019 damz. All rights reserved.
//

import Foundation
import PromiseKit

enum WeatherForeCastServiceError: Error {
    case wrongData
    case apiError(errorCode: Int)
    case urlError
    case jsonError
    case dataError
}

class WeatherForecastRequestService
{
    // Ask the api for the weather forecasts at a particular location
    func getWeatherForecastsForLocation(location: String) -> Promise<[HourlyWeatherForecast]?>{
        
        return Promise<[HourlyWeatherForecast]?> { seal in
            
            // Compose the url
            var urlStr = GlobalConstants.ForecastAPI.Url;
            urlStr += "_ll=" + location
            urlStr += "&_auth=" + GlobalConstants.ForecastAPI.Auth
            urlStr += "&_c=" + GlobalConstants.ForecastAPI.C
            let url = URL(string: urlStr)!
            
            // Trigger url request
            URLSession.shared.dataTask(with: url) { data, _, error in
                
                // Check data integrity, then parse json
                guard let data = data,
                    let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else {
                        seal.reject(error ?? WeatherForeCastServiceError.jsonError)
                        return
                }
                
                // Check returned code to check request status
                guard let returnCode = result["request_state"] as? Int else {
                    seal.reject(WeatherForeCastServiceError.wrongData)
                    return
                }
                
                // Status OK
                guard returnCode == 200 else {
                    seal.reject(WeatherForeCastServiceError.apiError(errorCode: returnCode))
                    return
                }
                
                // Parse forecasts from json
                guard let hourlyForecasts = self.parseWeatherForecastData(data: result), hourlyForecasts.isEmpty == false else {
                    seal.reject(WeatherForeCastServiceError.dataError)
                    return
                }
                
                // Everything ok, fulfill the promise
                seal.fulfill(hourlyForecasts)
            }.resume()
        }
    }
    
    // Parse data from json to extract hourly weather forecasts
    func parseWeatherForecastData(data : [String:Any]) -> [HourlyWeatherForecast]?
    {
        var hourlyWeatherForecasts : [HourlyWeatherForecast]?
        for (key, val) in data
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = HourlyWeatherForecast.dateFormatString
            // Checking if we are parsing a date.
            // Api doesnt gather all forecasts in one dictionary, so we need to check for every key...
            if let date = dateFormatter.date(from: key)
            {
                if (hourlyWeatherForecasts == nil)
                {
                    hourlyWeatherForecasts = [HourlyWeatherForecast]()
                }
                let hourlyWeatherForecast = HourlyWeatherForecast(date: date)
                // Parse corresponding data
                hourlyWeatherForecast.parseData(val as! [String : Any])
                hourlyWeatherForecasts?.append(hourlyWeatherForecast)
            }
        }
        return hourlyWeatherForecasts
    }
}
