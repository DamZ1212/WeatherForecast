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
    let cellId = "DailyForecastCell" // Cell reusable id
    let locationManager = CLLocationManager() // Location Manager: gather user location
    
    var presenter : WeatherForecastPresenter? // The linked presenter
    var dailyForecasts : [DailyForecastData]? // stored daily forecasts
    var alert : UIAlertController? // Current alert showed
    var lastKnownLocation : CLLocation? // User last known location
    weak var delegate: DailyForecastSelectionDelegate? // Delegate for cell selection
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Presenter creation
        self.presenter = WeatherForecastPresenter()
        // Attach self
        presenter?.attachView(self)
        // Trigger current location determination
        determineMyCurrentLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // View appeared, no stored forecasts => still in loading state
        if dailyForecasts == nil
        {
            showLoader()
        }
    }
    
    // Determine the current location of the user
    func determineMyCurrentLocation() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        // Launch location update
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    // Shows a loading alert
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

// CLLocationManagerDelegate
extension WeatherForecastListTableViewController
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        // No stored location
        if lastKnownLocation == nil
        {
            // Store the first one
            lastKnownLocation = userLocation
            // Stop asking for location
            manager.stopUpdatingLocation()
            print("user latitude = \(lastKnownLocation!.coordinate.latitude)")
            print("user longitude = \(lastKnownLocation!.coordinate.longitude)")
            
            let coordinates = String(lastKnownLocation!.coordinate.latitude) + "," + String(lastKnownLocation!.coordinate.longitude)
            // Ask the presenter for the forecasts according to this location
            presenter?.getDailyWeatherForecastsForLocation(location: coordinates);
        }
    }
}

// WeatherForecastView
extension WeatherForecastListTableViewController
{
    func setDailyForecasts(_ forecasts: [DailyForecastData]?)
    {
        // Forecasts received from the presenter
        if let pForecasts = forecasts, !pForecasts.isEmpty
        {
            // Store them
            self.dailyForecasts = forecasts
            // Call delegate to update details
            delegate?.dailyForecastSelected(self.dailyForecasts![0])
            // Reload current table data
            tableView.reloadData()
            // Dismiss alert if applicable
            self.dismiss(animated: true)
        }
        else
        {
            // No data received.
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
