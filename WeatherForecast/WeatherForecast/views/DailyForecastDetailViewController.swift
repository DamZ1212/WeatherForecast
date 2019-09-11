//
//  DailyForecastDetailViewController.swift
//  WeatherForecast
//
//  Created by Damien Bivaud on 11/09/2019.
//  Copyright © 2019 damz. All rights reserved.
//

import Foundation
import UIKit

class DailyForecastDetailViewController: UIViewController, DailyForecastSelectionDelegate {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    var dailyForecast: DailyForecastData? {
        didSet {
            refreshUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func refreshUI()
    {
        loadViewIfNeeded()
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE, d MMMM"
        let dateStr = dayFormatter.string(from: dailyForecast!.date!)
        dateLabel.text = dateStr
        icon.image = dailyForecast!.description?.getImage()
        temperatureLabel.text = String(Utils.convertKelvinToCelsius(dailyForecast!.temperature!).rounded(toPlaces: 1)) + "°"
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DailyForecastDetailViewController
{
    func dailyForecastSelected(_ dailyForecast: DailyForecastData)
    {
        self.dailyForecast = dailyForecast
    }
}
