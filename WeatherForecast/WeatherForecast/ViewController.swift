//
//  ViewController.swift
//  WeatherForecast
//
//  Created by Damien Bivaud on 10/09/2019.
//  Copyright © 2019 damz. All rights reserved.
//

import UIKit

class ViewController: UIViewController, WeatherForecastView{

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        var presenter = WeatherForecastPresenter()
        presenter.attachView(self)
        presenter.getDailyWeatherForecastsForLocation(location: "48.85341,2.3488");
    }
}

extension ViewController
{
    func setDailyForecasts(_ forecasts: [DailyForecastData]?)
    {
        print("Got data !")
    }
}

