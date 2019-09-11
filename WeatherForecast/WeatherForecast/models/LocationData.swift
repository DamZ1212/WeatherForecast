//
//  File.swift
//  WeatherForecast
//
//  Created by Damien Bivaud on 11/09/2019.
//  Copyright © 2019 damz. All rights reserved.
//

import Foundation
import CoreLocation

class LocationData
{
    let latitude: Double
    let longitude: Double
    let description: String

    init(_ location: CLLocationCoordinate2D, descriptionString: String) {
        latitude =  location.latitude
        longitude =  location.longitude
        description = descriptionString
    }
}
