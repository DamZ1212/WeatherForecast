//
//  WeatherForecastDay.swift
//  WeatherForecast
//
//  Created by Damien Bivaud on 10/09/2019.
//  Copyright © 2019 damz. All rights reserved.
//

import Foundation
import os.log

class HourlyWeatherForecast : NSObject, NSCoding
{
    struct PropertyKey
    {
        static let Date = "date"
        static let Temperature = "temperature"
        static let Rain = "rain"
        static let Pression = "pression"
        static let Humidity = "humidity"
        static let Nebulosity = "nebulosity"
        static let WindDirection = "wind_direction"
        static let WindForce = "wind_force"
    }
    
    var date : Date
    var temperature : Double? // temp in kelvin
    var rain : Int? // rain in mm
    var pression : Int? // pression
    var humidity : Double? // humidity
    var nebulosity : Int? // %
    var wind_direction : Int? // degrees
    var wind_force : Double? // km/h
    
    init(date: Date)
    {
        self.date = date
    }
    
    init(date: Date, temperature: Double, rain : Int, pression: Int, humidity: Double, nebulosity: Int, wind_direction : Int, wind_force: Double)
    {
        self.date = date
        self.temperature = temperature
        self.rain = rain
        self.pression = pression
        self.humidity = humidity
        self.nebulosity = nebulosity
        self.wind_direction = wind_direction
        self.wind_force = wind_force
    }
    
    func parseData(_ data: [String:Any])
    {
        if let temperature = data["temperature"] as? [String:Any]
        {
            self.temperature = temperature["2m"] as? Double
        }
        if let rain = data["pluie"] as? Int
        {
            self.rain = rain
        }
        if let pression = data["pression"] as? [String:Any]
        {
            self.pression = pression["niveau_de_la_mer"] as? Int
        }
        if let humidity = data["humidite"] as? [String:Any]
        {
            self.humidity = humidity["2m"] as? Double
        }
        if let nebulosity = data["nebulosite"] as? [String:Any]
        {
            self.nebulosity = nebulosity["totale"] as? Int
        }
        if let wind_direction = data["vent_direction"] as? [String:Any]
        {
            self.wind_direction = wind_direction["10m"] as? Int
        }
        if let wind_force = data["vent_moyen"] as? [String:Any]
        {
            self.wind_force = wind_force["10m"] as? Double
        }
    }
    
    func encode(with aCoder: NSCoder) {
        print(self)
        aCoder.encode(date, forKey: PropertyKey.Date)
        aCoder.encode(temperature ?? 0, forKey: PropertyKey.Temperature)
        aCoder.encode(rain ?? 0, forKey: PropertyKey.Rain)
        aCoder.encode(pression ?? 0, forKey: PropertyKey.Pression)
        aCoder.encode(humidity ?? 0, forKey: PropertyKey.Humidity)
        aCoder.encode(nebulosity ?? 0, forKey: PropertyKey.Nebulosity)
        aCoder.encode(wind_direction ?? 0, forKey: PropertyKey.WindDirection)
        aCoder.encode(wind_force ?? 0, forKey: PropertyKey.WindForce)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let decodedDate = aDecoder.decodeObject(forKey: PropertyKey.Date) as! Date
        let decodedTemp = aDecoder.decodeObject(forKey: PropertyKey.Temperature) as? Double ?? 0
        let decodedRain = aDecoder.decodeObject(forKey: PropertyKey.Rain) as? Int ?? 0
        let decodedPression = aDecoder.decodeObject(forKey: PropertyKey.Pression) as? Int ?? 0
        let decodedHumidity = aDecoder.decodeObject(forKey: PropertyKey.Humidity) as? Double ?? 0
        let decodedNebulosity = aDecoder.decodeObject(forKey: PropertyKey.Nebulosity) as? Int ?? 0
        let decodedWindDir = aDecoder.decodeObject(forKey: PropertyKey.WindDirection) as? Int ?? 0
        let decodedWindForce = aDecoder.decodeObject(forKey: PropertyKey.WindForce) as? Double ?? 0
        
        self.init(date: decodedDate, temperature: decodedTemp, rain: decodedRain, pression: decodedPression, humidity: decodedHumidity, nebulosity: decodedNebulosity, wind_direction: decodedWindDir, wind_force: decodedWindForce)
    }
    
    override var description: String { return String("Date: \(date), Temperature: \(temperature), Rain: \(rain), Pression: \(pression), Humidity: \(humidity), Nebulosity: \(nebulosity), Wind direction: \(wind_direction), Wind Force: \(wind_force)") }
}

class WeatherForecastData
{
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ForecastDataURL = DocumentsDirectory.appendingPathComponent("forecasts")
    static let UserDefaultKey = "WeatherForecastData"
    
    var hourlyWeatherForecasts : [HourlyWeatherForecast]
    
    init()
    {
        self.hourlyWeatherForecasts = [HourlyWeatherForecast]()
    }
    
    func addHourlyForecast(forecast: HourlyWeatherForecast)
    {
        hourlyWeatherForecasts.append(forecast)
    }
    
    func cleanUp()
    {
        hourlyWeatherForecasts.removeAll()
    }
    
    func saveOnDisk()
    {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: self.hourlyWeatherForecasts as Any, requiringSecureCoding: false)
            try data.write(to: WeatherForecastData.ForecastDataURL)
            UserDefaults.standard.set(data, forKey: WeatherForecastData.UserDefaultKey)
            os_log("Forecasts successfully saved.", log: OSLog.default, type: .debug)
        }
        catch
        {
            os_log("Failed to save forecasts...", log: OSLog.default, type: .error)
        }
    }
    
    func loadFromDisk()
    {
        if let unarchivedObject = UserDefaults.standard.data(forKey: WeatherForecastData.UserDefaultKey)
        {
            do {
                try self.hourlyWeatherForecasts = NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(unarchivedObject) as! [HourlyWeatherForecast]
            }
            catch
            {
                os_log("Forecast data not found...", log: OSLog.default, type: .error)
            }
        }
    }
}
