//
//  Constants.swift
//  WeatherForecast
//
//  Created by Damien Bivaud on 10/09/2019.
//  Copyright © 2019 damz. All rights reserved.
//

import Foundation

struct GlobalConstants {
    struct ForecastAPI
    {
        static let Url : String = "http://www.infoclimat.fr/public-api/gfs/json?"
        static var Auth : String = "CBJfSFQqVHYCLwQzAnQLIgdvBzIAdgUiUCwCYQ1oXyIBagVkBGQBZ14wUi8GKVVjByoPbAgzUGADaFIqWCpXNghiXzNUP1QzAm0EYQItCyAHKQdmACAFIlA7AmYNfl89AWMFZQR5AWJeMVIuBjdVZgc8D3AIKFBpA2VSM1g9VzUIb186VDJUMwJrBHkCLQs6B2AHYAA4BWtQMwIzDWRfNQEwBWYEZwEyXjFSLgYwVWUHNg9pCD9QaQNhUjVYKlcrCBJfSFQqVHYCLwQzAnQLIgdhBzkAaw%3D%3D"
        static var C : String = "11273c1f62ff7cbcb90be20ffe46e69e"
        
        static let DateFormatString = "yyyy-MM-dd HH:mm:ss"
    }
    
    struct LocalSave
    {
        static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        static let DataURL = DocumentsDirectory.appendingPathComponent("weatherForecasts")
        static let UserDefaultKey = "WeatherForecastData"
    }
    
    struct Config
    {
        static let RequestTimeoutInterval : TimeInterval = 60
    }
}
