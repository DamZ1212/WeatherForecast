//
//  WeatherForecastRequestService.swift
//  WeatherForecast
//
//  Created by Damien Bivaud on 10/09/2019.
//  Copyright © 2019 damz. All rights reserved.
//

import Foundation
import PromiseKit

class WeatherForecastRequestService
{
    // Ask the api for the weather forecasts at a particular location
    func getWeatherForecastsForLocation(location: String, callback:@escaping ([HourlyWeatherForecast]?) -> Void) {
        
        // Compose the url to call
        var url = GlobalConstants.ForecastAPI.Url;
        url += "_ll=" + location
        url += "&_auth=" + GlobalConstants.ForecastAPI.Auth
        url += "&_c=" + GlobalConstants.ForecastAPI.C
        
        query(url: url, completion: {data, response, error in
            do
            {
                guard let jsonData = data, jsonData.isEmpty == false else
                {
                    DispatchQueue.main.async {callback(nil)}
                    return;
                }
                guard error == nil else
                {
                    DispatchQueue.main.async {callback(nil)}
                    return;
                }
                do
                {
                    if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
                    {
                        if let request_state = json["request_state"] as? String, request_state == "200"
                        {
                            let hourlyForecast = self.parseWeatherForecastData(data: json)
                            DispatchQueue.main.async {callback(hourlyForecast)}
                            return;
                        }
                        else
                        {
                            DispatchQueue.main.async {callback(nil)}
                            return;
                        }
                    }
                    else
                    {
                        DispatchQueue.main.async {callback(nil)}
                        return;
                    }
                }
            }
            catch
            {
                print(error)
            }
        })
    }
    
    // Parse data from json to extract hourly weather forecasts
    func parseWeatherForecastData(data : [String:Any]) -> [HourlyWeatherForecast]?
    {
        var hourlyWeatherForecasts : [HourlyWeatherForecast]?
        for (key, val) in data
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
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
    
    // Query utility method
    func query(url: String, completion: @escaping (Data?, URLResponse?, Error?) -> ())
    {
        if let url = URL(string: url)
        {
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: GlobalConstants.Config.RequestTimeoutInterval)
            let query = URLSession.shared.dataTask(with: request, completionHandler: completion)
            query.resume()
        }
    }
}
