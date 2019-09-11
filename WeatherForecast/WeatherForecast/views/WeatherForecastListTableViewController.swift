//
//  WeatherForecastListTableViewController.swift
//  WeatherForecast
//
//  Created by Damien Bivaud on 11/09/2019.
//  Copyright © 2019 damz. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

protocol DailyForecastSelectionDelegate : class {
    func dailyForecastSelected(_ dailyForecast: DailyForecastData)
}

class WeatherForecastListTableViewController: UITableViewController, WeatherForecastView, CLLocationManagerDelegate
{
    let cellId = "DailyForecastCell"
    let locationManager = CLLocationManager()
    
    var presenter : WeatherForecastPresenter?
    var dailyForecasts : [DailyForecastData]?
    var alert : UIAlertController?
    var lastKnownLocation : CLLocation?
    weak var delegate: DailyForecastSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presenter = WeatherForecastPresenter()
        presenter?.attachView(self)
        determineMyCurrentLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if dailyForecasts == nil
        {
            showLoader()
        }
    }
    
    func determineMyCurrentLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func showLoader()
    {
        self.alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        self.alert!.view.addSubview(loadingIndicator)
        present(self.alert!, animated: true, completion: nil)
    }
}

extension WeatherForecastListTableViewController
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        if lastKnownLocation == nil
        {
            lastKnownLocation = userLocation
            manager.stopUpdatingLocation()
            print("user latitude = \(lastKnownLocation!.coordinate.latitude)")
            print("user longitude = \(lastKnownLocation!.coordinate.longitude)")
            
            let coordinates = String(lastKnownLocation!.coordinate.latitude) + "," + String(lastKnownLocation!.coordinate.longitude)
            presenter?.getDailyWeatherForecastsForLocation(location: coordinates);
        }
    }
}

// WeatherForecastView
extension WeatherForecastListTableViewController
{
    func setDailyForecasts(_ forecasts: [DailyForecastData]?)
    {
        if let pForecasts = forecasts, !pForecasts.isEmpty
        {
            self.dailyForecasts = forecasts
            delegate?.dailyForecastSelected(self.dailyForecasts![0])
            tableView.reloadData()
            self.dismiss(animated: true)
        }
        else
        {
            // Dismiss current alert, and trigger error afterwards
            self.dismiss(animated: true) {
                OperationQueue.main.addOperation {
                    self.alert = UIAlertController(title: "Error", message: "Could not gather weatherforecast data. Please try again later.", preferredStyle: .alert)
                    self.present(self.alert!, animated: true, completion: nil)
                }
            }
        }
    }
}

// Table View extensions
extension WeatherForecastListTableViewController
{
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.dailyForecasts == nil
        {
            return 0
        }
        return self.dailyForecasts!.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? DailyForecastTableViewCell
        {
            let forecast = dailyForecasts![indexPath.row]
            cell.dailyForecast = forecast
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let forecast = dailyForecasts![indexPath.row]
        delegate?.dailyForecastSelected(forecast)
        
        if let detailViewController = delegate as? DailyForecastDetailViewController {
            splitViewController?.showDetailViewController(detailViewController, sender: nil)
        }
    }
}
