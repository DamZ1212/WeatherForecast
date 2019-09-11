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
        dateLabel.text = dailyForecast!.date?.description
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
