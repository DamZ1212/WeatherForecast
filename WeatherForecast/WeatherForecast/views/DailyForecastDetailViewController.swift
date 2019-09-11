//
//  DailyForecastDetailViewController.swift
//  WeatherForecast
//
//  Created by Damien Bivaud on 11/09/2019.
//  Copyright © 2019 damz. All rights reserved.
//

import Foundation
import UIKit

class DailyForecastDetailViewController: UIViewController, DailyForecastSelectionDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private let reuseIdentifier = "HourlyForecastCell"
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var hourlyForecastCollectionView: UICollectionView!
    
    @IBOutlet weak var rainSummaryDetail: DailySummaryItemView!
    @IBOutlet weak var pressureSummaryDetail: DailySummaryItemView!
    @IBOutlet weak var humiditySummaryDetail: DailySummaryItemView!
    @IBOutlet weak var windDirSummaryDetail: DailySummaryItemView!
    @IBOutlet weak var windForceSummaryDetail: DailySummaryItemView!
    
    var dailyForecast: DailyForecastData? {
        didSet {
            refreshUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        hourlyForecastCollectionView.delegate = self
        hourlyForecastCollectionView.dataSource = self
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 100, height: 160)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0.0
        hourlyForecastCollectionView.collectionViewLayout = flowLayout
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
        rainSummaryDetail.configure(image: UIImage(named: "water")!, textContent: String(dailyForecast!.rain!) + " mm")
        pressureSummaryDetail.configure(image: UIImage(named: "meter")!, textContent: String(dailyForecast!.pressure!) + " Pa")
        humiditySummaryDetail.configure(image: UIImage(named: "humidity")!, textContent: String(dailyForecast!.humidity!.rounded()) + " %")
        windDirSummaryDetail.configure(image: UIImage(named: "navigation")!, textContent: String(dailyForecast!.windDirection!) + " °")
        windForceSummaryDetail.configure(image: UIImage(named: "wind")!, textContent: String(dailyForecast!.windForce!.rounded()) + " km/h")
    }
}

extension DailyForecastDetailViewController
{
    func dailyForecastSelected(_ dailyForecast: DailyForecastData)
    {
        self.dailyForecast = dailyForecast
    }
}

extension DailyForecastDetailViewController
{
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int
    {
        return self.dailyForecast!.hourlyForecasts!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? HourlyForecastCollectionViewCell
        {
            let forecast = dailyForecast!.hourlyForecasts![indexPath.row]
            cell.setHourlyForecast(forecast)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: 100, height: 160)
    }
}
