//
//  ParkingSearchCriteria.swift
//  ParkingMeow
//
//  Created by Chris Kwok on 23/12/2015.
//  Copyright © 2015 The Meow Meow Inc. All rights reserved.
//

import UIKit
import CoreLocation

class ParkingSearchCriteria {

    private(set) var hourTypes: [ParkingBusinessHour.HourType : Bool] = [ : ]
    private(set) var rateTypes: [ParkingRate.RateType : Double] = [ : ]
    var coordinate: CLLocationCoordinate2D?

    var requestParameters: [String : AnyObject] {
        var dict = [String : AnyObject]()
        if let coordinate = coordinate {
            dict["longtitude"] = coordinate.longitude
            dict["latitude"] = coordinate.latitude
        }

        for (k, v) in hourTypes {
            dict[k.rawValue] = v
        }

        for (k, v) in rateTypes {
            dict[k.rawValue] = v
        }

        return dict
    }

    func includeBusinessHour(hourType: ParkingBusinessHour.HourType, on: Bool) {
        hourTypes[hourType] = on
    }

    func includeRate(rateType: ParkingRate.RateType, price: Double) {
        rateTypes[rateType] = price
    }

    func reset() {
        coordinate = nil
        hourTypes.removeAll()
        rateTypes.removeAll()
    }
}
