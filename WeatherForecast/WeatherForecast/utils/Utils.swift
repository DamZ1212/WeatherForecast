//
//  Utils.swift
//  WeatherForecast
//
//  Created by Damien Bivaud on 11/09/2019.
//  Copyright © 2019 damz. All rights reserved.
//

import Foundation

class Utils
{
    // Kalvin to celsius degrees
    static func convertKelvinToCelsius(_ kelvin: Double) -> Double
    {
        return kelvin - 273.15
    }
}

// Rounded extension to double to show "places" digits after coma
extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
