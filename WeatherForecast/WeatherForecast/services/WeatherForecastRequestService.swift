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
}

class WeatherForecastRequestService
{
    // Ask the api for the weather forecasts at a particular location
    func getWeatherForecastsForLocation(location: String) -> Promise<[HourlyWeatherForecast]?>{
        
        return Promise<[HourlyWeatherForecast]?> { seal in
            var urlStr = GlobalConstants.ForecastAPI.Url;
            urlStr += "_ll=" + location
            urlStr += "&_auth=" + GlobalConstants.ForecastAPI.Auth
            urlStr += "&_c=" + GlobalConstants.ForecastAPI.C
            let url = URL(string: urlStr)!
            
            URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data,
                    let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else {
                        seal.reject(error ?? WeatherForeCastServiceError.jsonError)
                        return
                }
                guard let returnCode = result["request_state"] as? Int else {
                    seal.reject(WeatherForeCastServiceError.wrongData)
                    return
                }
                guard returnCode == 200 else
                {
                    seal.reject(WeatherForeCastServiceError.apiError(errorCode: returnCode))
                    return
                }
                let hourlyForecasts = self.parseWeatherForecastData(data: result)
                seal.fulfill(hourlyForecasts!)
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
            // Api doesnt gather all forecasts in one dictionary...
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
