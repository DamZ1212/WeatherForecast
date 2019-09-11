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
    
    func getWeatherForecastsForLocation(location: String, callback:@escaping ([HourlyWeatherForecast]?) -> Void) {
        
        var url = GlobalConstants.Forecast.APIUrl;
        url += "_ll=" + location
        url += "&"
        url += "_auth=" + GlobalConstants.Forecast.AuthKey
        url += "&"
        url += "_c=" + GlobalConstants.Forecast.AuthToken
        
        query(url: url, completion: {data, response, error in
            do
            {
                // Check for correct return code ! //200
                let hourlyForecast = try self.parseWeatherForecastData(data: data!)
                DispatchQueue.main.async {callback(hourlyForecast)}
            }
            catch
            {
                print(error)
                DispatchQueue.main.async {callback(nil)}
            }
        })
    }
    
    func parseWeatherForecastData(data : Data) throws -> [HourlyWeatherForecast]?
    {
        var hourlyWeatherForecasts : [HourlyWeatherForecast]?
        do
        {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
            {
                for (key, val) in json
                {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    if let date = dateFormatter.date(from: key)
                    {
                        if (hourlyWeatherForecasts == nil)
                        {
                            hourlyWeatherForecasts = [HourlyWeatherForecast]()
                        }
                        let hourlyWeatherForecast = HourlyWeatherForecast(date: date)
                        hourlyWeatherForecast.parseData(val as! [String : Any])
                        hourlyWeatherForecasts?.append(hourlyWeatherForecast)
                    }
                }
            }
        }
        catch
        {
            throw(error)
        }
        return hourlyWeatherForecasts
    }
    
    func query(url: String, completion: @escaping (Data?, URLResponse?, Error?) -> ())
    {
        if let url = URL(string: url)
        {
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: GlobalConstants.Config.RequestTimeoutInterval)
            let query = URLSession.shared.dataTask(with: request, completionHandler: completion)
            // error ?
            query.resume()
        }
    }
}
