//
//  SearchTableViewController.swift
//  ParkingMeow
//
//  Created by Chris Kwok on 3/12/2015.
//  Copyright © 2015 The Meow Meow Inc. All rights reserved.
//

import UIKit
import MapKit

class SearchTableViewController: UITableViewController {

    private let sectionCnt = 2
    private let rowCntForRateSection = 4
    private let rowCntForHourSection = 3

    @IBOutlet weak var monFriSwitch: UISwitch!
    @IBOutlet weak var satSwitch: UISwitch!
    @IBOutlet weak var sunSwitch: UISwitch!

    @IBOutlet weak var rate1HrTextField: UITextField!
    @IBOutlet weak var rate2HrTextField: UITextField!
    @IBOutlet weak var rate3HrTextField: UITextField!
    @IBOutlet weak var rateAllDayTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func buildGetParkingRequest() -> GetParkingRequest {
        let request = GetParkingRequest()
        request.includeBusinessHour(ParkingBusinessHour.HourType.MonFri, on: monFriSwitch.on)
        request.includeBusinessHour(ParkingBusinessHour.HourType.Sat, on: satSwitch.on)
        request.includeBusinessHour(ParkingBusinessHour.HourType.Sun, on: sunSwitch.on)

        if let text = rate1HrTextField.text, price = Double(text) {
            request.includeRate(ParkingRate.RateType.OneHour, price: price)
        }

        if let text = rate2HrTextField.text, price = Double(text) {
            request.includeRate(ParkingRate.RateType.TwoHour, price: price)
        }

        if let text = rate3HrTextField.text, price = Double(text) {
            request.includeRate(ParkingRate.RateType.ThreeHour, price: price)
        }

        if let text = rateAllDayTextField.text, price = Double(text) {
            request.includeRate(ParkingRate.RateType.AllDay, price: price)
        }

        return request
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionCnt
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0: return rowCntForRateSection
            case 1: return rowCntForHourSection
            default: return 0
        }
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showDetail" {
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! MapViewController
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }
}
