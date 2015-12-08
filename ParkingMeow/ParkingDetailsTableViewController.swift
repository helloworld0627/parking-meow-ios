//
//  ParkingDetailsTableViewController.swift
//  ParkingMeow
//
//  Created by Chris Kwok on 6/12/2015.
//  Copyright © 2015 The Meow Meow Inc. All rights reserved.
//

import UIKit

class ParkingDetailsTableViewController: UITableViewController {

    let reuseIdentifier = "parkingDetailCell"
    let notAvailableStr = "N/A"
    let sectionNames = ["Rates", "Business Hours", "Details"]

    let numberFormatter : NSNumberFormatter = {
        var f = NSNumberFormatter()
        f.numberStyle = .CurrencyStyle
        return f
    }()


    let rateDisplayNames = [
        ParkingRate.RateType.OneHour : "1 HR",
        ParkingRate.RateType.TwoHour : "2 HR",
        ParkingRate.RateType.ThreeHour : "3 HR",
        ParkingRate.RateType.AllDay : "All Day",
    ]

    let businessHourDisplayNames = [
        ParkingBusinessHour.HourType.MonFri : "Mon - Fri",
        ParkingBusinessHour.HourType.Sat : "Sat",
        ParkingBusinessHour.HourType.Sun : "Sun",
    ]

    var rateCellContentTuples : [(String , String?)]?
    var businessHourCellContentTuples : [(String , String?)]?
    var detailContentTuples : [(String, String?)]?


    var parkingLot : ParkingLot? {
        didSet {
            rateCellContentTuples = {
                var tuples = [(String , String?)]()
                if let rates = parkingLot?.parkingRates {
                    for rate in rates {
                        var priceStr = notAvailableStr
                        if let rateType = rate.rateType, displayName = rateDisplayNames[rateType] {
                            if let price = rate.price where Double(price) > 0 {
                                priceStr = numberFormatter.stringFromNumber(price)!
                            }
                            tuples.append((displayName, priceStr))
                        }
                    }
                }
                return tuples
            }()

            businessHourCellContentTuples =  {
                var tuples = [(String , String?)]()
                if let hours = parkingLot?.parkingBusinessHours {
                    for hour in hours {
                        if let fromTo = hour.fromTo, hourType = hour.hourType, displayName = businessHourDisplayNames[hourType] {
                            tuples.append((displayName, fromTo))
                        }
                    }
                }
                return tuples
            }()

            detailContentTuples = {
                // name
                let nameVal = (parkingLot?.webname != nil) ? parkingLot?.webname : (parkingLot?.facName != nil) ? parkingLot?.facName : parkingLot?.opName
                let name : (String, String?) = ("name", nameVal)
                //address
                let address : (String, String?) = ("address", parkingLot?.deaFacilityAddress)
                // web
                let web : (String, String?) = ("web", parkingLot?.opWeb)
                // phone
                let phoneVal = (parkingLot?.opPhone != nil) ? parkingLot?.opPhone : parkingLot?.opPhone2
                let phone : (String, String?) = ("phone", phoneVal)
                // stall
                let stallVal : String? = (parkingLot?.deaStalls != nil) ? String((parkingLot?.deaStalls)!) : nil
                let stall : (String, String?) = ("total stalls", stallVal)
                // disabled
                let disabledVal : String? = (parkingLot?.disabled != nil) ? String((parkingLot?.disabled)!) : nil
                let disabled : (String, String?) = ("total disabled", disabledVal)
                // vacant
                let vacantVal : String? = (parkingLot?.vacant != nil) ? String((parkingLot?.vacant)!) : nil
                let vacant : (String, String?) = ("total vacant", vacantVal)
                // all
                let tuples : [(String, String?)]? = [name, address, web, phone, stall, disabled, vacant]
                return tuples
            }()

            tableView.reloadData()
        }
    }

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

    private func getContentTuples(section : Int) -> [(String, String?)]? {
        switch section {
        case 0:
            return rateCellContentTuples
        case 1:
            return businessHourCellContentTuples
        case 2:
            return detailContentTuples
        default:
            return nil
        }
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionNames.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tuples = getContentTuples(section) {
            return tuples.count
        }
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        let section = indexPath.section
        let tuples = getContentTuples(section)
        if let tuple = tuples?[indexPath.item] {
            cell.textLabel?.text = tuple.0
            var detailTextVal = notAvailableStr
            if let val = tuple.1 {
                detailTextVal = val
            }
            cell.detailTextLabel?.text = detailTextVal
        }

        return cell
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionNames[section]
    }

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
