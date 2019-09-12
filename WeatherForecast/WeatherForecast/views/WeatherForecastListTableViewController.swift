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
        locationManager.requestWhenInUseAuthorization()
        
        // Launch location request
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
        }
        else
        {
            showAlert(title: "Error", message: "Failed to retrieve your location. Please authorize the app to access your location data.")
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
    
    func showAlert(title: String, message: String)
    {
        self.dismiss(animated: true) {
            OperationQueue.main.addOperation {
                self.alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                self.present(self.alert!, animated: true, completion: nil)
            }
        }
    }
}

// CLLocationManagerDelegate
extension WeatherForecastListTableViewController
{
    // Handling the location we asked for
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        let coordinates = String(userLocation.coordinate.latitude) + "," + String(userLocation.coordinate.longitude)
        // Ask the presenter for the forecasts according to this location
        presenter?.getDailyWeatherForecastsForLocation(location: coordinates);
    }
    
    // Failed to retrieve the location for some reason
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showAlert(title: "Error", message: "Failed to retrieve your location. Please authorize the app to access your location data.")
    }
    
    // User just authorized the location manager to be running, request it
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse
        {
            manager.requestLocation()
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
            showAlert(title: "Error", message: "Could not gather weatherforecast data. Please try again later.")
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
