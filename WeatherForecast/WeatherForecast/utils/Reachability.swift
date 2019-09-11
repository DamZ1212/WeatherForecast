//
//  Reachability.swift
//  WeatherForecast
//
//  Created by Damien Bivaud on 11/09/2019.
//  Copyright © 2019 damz. All rights reserved.
//

import Foundation
import Network

class Reachability{
    
    static let instance = Reachability()
    
    var currentPath : NWPath?
    
    private init()
    {
    }
    
    func startMonitoring()
    {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            self.currentPath = path
        }
        let queue = DispatchQueue(label: "Reachability")
        monitor.start(queue: queue)
    }
}
