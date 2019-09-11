//
//  HourlyForecastCollectionViewCell.swift
//  WeatherForecast
//
//  Created by Damien Bivaud on 11/09/2019.
//  Copyright © 2019 damz. All rights reserved.
//

import UIKit

class HourlyForecastCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    var hourlyForecast : HourlyForecast?
    {
        didSet {
            refreshUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func refreshUI()
    {
        let hourFormatter = DateFormatter()
        hourFormatter.dateFormat = "HH"
        let dateStr = hourFormatter.string(from: hourlyForecast!.date!)
        
        icon.image = hourlyForecast!.description?.getImage()
        hourLabel.text = dateStr + " h"
        temperatureLabel.text = String(Utils.convertKelvinToCelsius (hourlyForecast!.temperature!).rounded(toPlaces: 1)) + "°"
    }
    
    func setHourlyForecast(_ forecast : HourlyForecast)
    {
        self.hourlyForecast = forecast
    }
}
