//
//  WeatherForecastTests.swift
//  WeatherForecastTests
//
//  Created by Damien Bivaud on 10/09/2019.
//  Copyright © 2019 damz. All rights reserved.
//

import XCTest
@testable import WeatherForecast

class ForecastParsing: XCTestCase {
    
    var proper_data : Data?
    var wrong_data : Data?
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        if let path = Bundle.main.path(forResource: "forecast", ofType: "json") {
            var string : String
            do {
                string = try String(contentsOfFile: path, encoding: .utf8)
                proper_data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)!
            }
            catch
            {
                print(error)
            }
        }
        else
        {
            XCTFail("Could'nt get forecast.json")
        }
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        if let path = Bundle.main.path(forResource: "wrong_forecast", ofType: "json") {
            var string : String
            do {
                string = try String(contentsOfFile: path, encoding: .utf8)
                wrong_data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)!
            }
            catch
            {
                print(error)
            }
        }
        else
        {
            XCTFail("Could'nt get forecast.json")
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testForecastParsing() {
        if let json = try? JSONSerialization.jsonObject(with: proper_data!, options: []) as? [String:Any]
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = dateFormatter.date(from: "2019-09-19 05:00:00")
            let forecast = HourlyWeatherForecast(date: date!)
            forecast.parseData(json)
            
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "dd MM yyyy"
            XCTAssert(dateFormatterPrint.string(from: date!) == "19 09 2019")
            XCTAssert(forecast.temperature == 283.1)
            XCTAssert(forecast.rain == 0)
            XCTAssert(forecast.pressure == 102690)
            XCTAssert(forecast.humidity == 67.3)
            XCTAssert(forecast.nebulosity == 0)
            XCTAssert(forecast.wind_direction == 417)
            XCTAssert(forecast.wind_force == 17.3)
        }
    }
    
    func testWrongForecastParsing() {
        if let json = try? JSONSerialization.jsonObject(with: wrong_data!, options: []) as? [String:Any]
        {
            let forecast = HourlyWeatherForecast(date: Date())
            forecast.parseData(json)
            XCTAssert(forecast.temperature == nil)
            XCTAssert(forecast.rain == nil)
            XCTAssert(forecast.pressure == nil)
            XCTAssert(forecast.humidity == nil)
            XCTAssert(forecast.nebulosity == nil)
            XCTAssert(forecast.wind_direction == nil)
            XCTAssert(forecast.wind_force == nil)
        }
    }
    
}

class APICallParsing: XCTestCase {
    
    var service = WeatherForecastRequestService()
    var serviceCallbackData = Data()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        if let path = Bundle.main.path(forResource: "api_test", ofType: "json") {
            var string : String
            do {
                string = try String(contentsOfFile: path, encoding: .utf8)
                serviceCallbackData = string.data(using: String.Encoding.utf8, allowLossyConversion: false)!
            }
            catch
            {
                print(error)
            }
        }
        else
        {
            XCTFail("Could'nt get api_test.json")
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testServiceDataParsing() {
        if let json = try? JSONSerialization.jsonObject(with: serviceCallbackData, options: []) as? [String:Any]
        {
            let weatherForeCastData = service.parseWeatherForecastData(data: json)
            XCTAssert(weatherForeCastData != nil)
            XCTAssert(weatherForeCastData!.count > 0)
            
            let forecasts = weatherForeCastData!.sorted(by: { $0.date < $1.date })
            let forecast = forecasts[0]
            
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "yyyy-MM-dd HH:mm:ss"
            XCTAssert(dateFormatterPrint.string(from: forecast.date) == "2019-09-11 11:00:00")
            XCTAssert(forecast.temperature == 289)
            XCTAssert(forecast.pressure == 102470)
            XCTAssert(forecast.rain == 0)
            XCTAssert(forecast.humidity == 68.5)
        }
    }
}

class APICallEmptyResponse: XCTestCase {
    
    var service = WeatherForecastRequestService()
    var serviceCallbackData = Data()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        if let path = Bundle.main.path(forResource: "api_empty", ofType: "json") {
            var string : String
            do {
                string = try String(contentsOfFile: path, encoding: .utf8)
                serviceCallbackData = string.data(using: String.Encoding.utf8, allowLossyConversion: false)!
            }
            catch
            {
                print(error)
            }
        }
        else
        {
            XCTFail("Could'nt get api_empty.json")
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testServiceEmptyDataParsing() {
        if let json = try? JSONSerialization.jsonObject(with: serviceCallbackData, options: []) as? [String:Any]
        {
            let weatherForeCastData = service.parseWeatherForecastData(data: json)
            XCTAssert(weatherForeCastData == nil)
        }
    }
}

class DataStorage: XCTestCase {
    
    var service = WeatherForecastRequestService()
    var serviceCallbackData = Data()
    var weatherForecastData = WeatherForecastData()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        if let path = Bundle.main.path(forResource: "api_test", ofType: "json") {
            var string : String
            do {
                string = try String(contentsOfFile: path, encoding: .utf8)
                serviceCallbackData = string.data(using: String.Encoding.utf8, allowLossyConversion: false)!
            }
            catch
            {
                print(error)
            }
        }
        else
        {
            XCTFail("Could'nt get api_test.json")
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.weatherForecastData.cleanUp()
        _ = self.weatherForecastData.saveOnDisk()
    }
    
    func testDataStorageFlow() {
        if let json = try? JSONSerialization.jsonObject(with: serviceCallbackData, options: []) as? [String:Any]
        {
            let forecastDatas = service.parseWeatherForecastData(data: json)
            XCTAssert(forecastDatas != nil)
            for forecast in forecastDatas!
            {
                self.weatherForecastData.addHourlyForecast(forecast: forecast)
            }
            XCTAssert(self.weatherForecastData.hourlyWeatherForecasts.count == forecastDatas!.count)
            
            let saveRet = self.weatherForecastData.saveOnDisk()
            XCTAssert(saveRet)
            
            self.weatherForecastData.cleanUp()
            XCTAssert(self.weatherForecastData.hourlyWeatherForecasts.count == 0)
            
            let loadRet = self.weatherForecastData.loadFromDisk()
            XCTAssert(loadRet)
            XCTAssert(self.weatherForecastData.hourlyWeatherForecasts.count == forecastDatas!.count)
        }
    }
}

