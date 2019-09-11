//
//  WeatherForecastListTableViewController.swift
//  WeatherForecast
//
//  Created by Damien Bivaud on 11/09/2019.
//  Copyright © 2019 damz. All rights reserved.
//

import Foundation
import UIKit

protocol DailyForecastSelectionDelegate : class {
    func dailyForecastSelected(_ dailyForecast: DailyForecastData)
}

class WeatherForecastListTableViewController: UITableViewController, WeatherForecastView
{
    let cellId = "dailyForecastCell"
    
    var presenter : WeatherForecastPresenter?
    var dailyForecasts : [DailyForecastData]?
    weak var delegate: DailyForecastSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presenter = WeatherForecastPresenter()
        presenter?.attachView(self)
        presenter?.getDailyWeatherForecastsForLocation(location: "48.85341,2.3488");
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
}

// WeatherForecastView
extension WeatherForecastListTableViewController
{
    func setDailyForecasts(_ forecasts: [DailyForecastData]?)
    {
        self.dailyForecasts = forecasts
        tableView.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let forecast = dailyForecasts![indexPath.row]
        cell.textLabel?.text = forecast.date!.description + " : " + forecast.temperature!.description
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let forecast = dailyForecasts![indexPath.row]
        delegate?.dailyForecastSelected(forecast)
        
        if let detailViewController = delegate as? DailyForecastDetailViewController {
            splitViewController?.showDetailViewController(detailViewController, sender: nil)
        }
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}
