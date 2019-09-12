//
//  DailyForecastTableViewCell.swift
//  WeatherForecast
//
//  Created by Damien Bivaud on 11/09/2019.
//  Copyright © 2019 damz. All rights reserved.
//

import UIKit

class DailyForecastTableViewCell: UITableViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    var dailyForecast : DailyForecastData?
    {
        didSet {
            refreshUI()
        }
    }
    
    // Refresh the current view
    func refreshUI()
    {
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE, d MMMM"
        let dateStr = dayFormatter.string(from: dailyForecast!.date!)
        
        icon.image = dailyForecast!.description?.getImage()
        dateLabel.text = dateStr
        temperatureLabel.text = String(Utils.convertKelvinToCelsius (dailyForecast!.temperature!).rounded(toPlaces: 1)) + "°"
    }
    
    func setDailyForecast(_ forecast : DailyForecastData)
    {
        self.dailyForecast = forecast
    }

}
