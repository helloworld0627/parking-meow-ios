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

    var rateCellContentTuples: [(name: String , val: String?, action: (Void -> Void)?)]?
    var businessHourCellContentTuples: [(name: String , val: String?, action: (Void -> Void)?)]?
    var detailCellContentTuples: [(name: String , val: String?, action: (Void -> Void)?)]?

    var parkingLot : ParkingLot? {
        didSet {
            rateCellContentTuples = getRateCellContentTuples()
            businessHourCellContentTuples = getBusinessHourCellContentTuples()
            detailCellContentTuples = getDetailCellContentTuples()
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

    private func getContentTuples(section : Int) -> [(name: String, val: String?, action: (Void -> Void)?)]? {
        switch section {
        case 0:
            return rateCellContentTuples
        case 1:
            return businessHourCellContentTuples
        case 2:
            return detailCellContentTuples
        default:
            return nil
        }
    }

    private func getRateCellContentTuples() -> [(name: String , val: String?, action: (Void -> Void)?)] {
        var tuples: [(name: String , val: String?, action: (Void -> Void)?)] = []
        if let rates = parkingLot?.parkingRates {
            for rate in rates {
                var priceStr = notAvailableStr
                if let rateType = rate.rateType, displayName = rateDisplayNames[rateType] {
                    if let price = rate.price where Double(price) > 0 {
                        priceStr = numberFormatter.stringFromNumber(price)!
                    }
                    tuples.append((name: displayName, val: priceStr, action: nil))
                }
            }
        }
        return tuples
    }

    private func getBusinessHourCellContentTuples() -> [(name: String , val: String?, action: (Void -> Void)?)] {
        var tuples: [(name: String , val: String?, action: (Void -> Void)?)] = []
        if let hours = parkingLot?.parkingBusinessHours {
            for hour in hours {
                if let fromTo = hour.fromTo, hourType = hour.hourType, displayName = businessHourDisplayNames[hourType] {
                    tuples.append((displayName, fromTo, nil))
                }
            }
        }
        return tuples
    }

    private func getDetailCellContentTuples() -> [(name: String , val: String?, action: (Void -> Void)?)] {
        // name
        let nameVal = (parkingLot?.webname != nil) ? parkingLot?.webname : (parkingLot?.facName != nil) ? parkingLot?.facName : parkingLot?.opName
        let name: (String, String?, (Void -> Void)?) = ("name", nameVal, nil)
        //address
        let address: (String, String?, (Void -> Void)?) = ("address", parkingLot?.deaFacilityAddress, nil)
        // web
        var webAction: (Void -> Void)? = nil
        if let urlString = self.parkingLot?.opWeb, url = NSURL(string: urlString) {
            webAction = {
                let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    UIApplication.sharedApplication().openURL(url)
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                let vc: UIAlertController = UIAlertController(title: "Open with web browser?", message: "", preferredStyle: .Alert)
                vc.addAction(alertAction)
                vc.addAction(cancelAction)
                self.presentViewController(vc, animated: true, completion: nil)
            }
        }
        let web: (String, String?, (Void -> Void)?) = ("web", parkingLot?.opWeb, webAction)
        // phone
        var phoneAction: (Void -> Void)? = nil
        let phoneVal = (parkingLot?.opPhone != nil) ? parkingLot?.opPhone : parkingLot?.opPhone2
        if let urlString = phoneVal {
            let replaced = String(urlString.characters.map {
                if $0 == "(" || $0 == ")" || $0 == "-" {
                    return " "
                } else {
                    return $0
                }
            })
            let noWhiteSpace = replaced.stringByReplacingOccurrencesOfString(" ", withString: "")
            let url = NSURL(string: "tel://" + noWhiteSpace)
            phoneAction = {
                let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    if UIApplication.sharedApplication().canOpenURL(url!) {
                        UIApplication.sharedApplication().openURL(url!)
                    }
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                let vc: UIAlertController = UIAlertController(title: "Open with phone app?", message: "", preferredStyle: .Alert)
                vc.addAction(alertAction)
                vc.addAction(cancelAction)
                self.presentViewController(vc, animated: true, completion: nil)
            }
        }

        let phone: (String, String?, (Void -> Void)?) = ("phone", phoneVal, phoneAction)
        // stall
        let stallVal : String? = (parkingLot?.deaStalls != nil) ? String((parkingLot?.deaStalls)!) : nil
        let stall: (String, String?, (Void -> Void)?) = ("total stalls", stallVal, nil)
        // disabled
        let disabledVal: String? = (parkingLot?.disabled != nil) ? String((parkingLot?.disabled)!) : nil
        let disabled: (String, String?, (Void -> Void)?) = ("total disabled", disabledVal, nil)
        // vacant
        let vacantVal: String? = (parkingLot?.vacant != nil) ? String((parkingLot?.vacant)!) : nil
        let vacant: (String, String?, (Void -> Void)?) = ("total vacant", vacantVal, nil)
        // all
        let tuples: [(name: String, val: String?, action: (Void -> Void)?)] = [name, address, web, phone, stall, disabled, vacant]
        return tuples
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

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let section = indexPath.section
        let row = indexPath.item
        guard let tuples = getContentTuples(section) else {
            return
        }
        if let action = tuples[row].action {
            action()
        }
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
