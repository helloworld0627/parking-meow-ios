//
//  ParkingMeowAPIClient.swift
//  ParkingMeow
//
//  Created by Chris Kwok on 1/12/2015.
//  Copyright © 2015 The Meow Meow Inc. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import Mantle

class ParkingMeowAPIClient {

    static let sharedInstance = ParkingMeowAPIClient()

    private let localhost = "http://localhost:3000"
    private let apiPath: String?
    private var parameters = [String : AnyObject]()

    private init() {
        let path = "/parking_lots"
        let hostkey = "ParkingMeow host"
        if let host = NSBundle.mainBundle().objectForInfoDictionaryKey(hostkey) as? String {
            self.apiPath = host + path
            return
        }
        print("host key \(hostkey) is not found in info.plist. use localhost")
        self.apiPath = localhost + path
    }

    func includeBusinessHour(hourType: ParkingBusinessHour.HourType, on: Bool) {
        parameters[hourType.rawValue] = on ? "true" : "false"
    }

    func includeRate(rateType: ParkingRate.RateType, price: Double) {
        parameters[rateType.rawValue] = price
    }

    func includeLocation(coordinate : CLLocationCoordinate2D) {
        parameters["longtitude"] = coordinate.longitude
        parameters["latitude"] = coordinate.latitude
    }

    func reset() {
        parameters = [String : AnyObject]()
    }

    func getParkingLots(completion: ((parkingLots : [ParkingLot]?, error : NSError?) -> Void) ) {
        debugPrint(parameters)
        guard let apiPath = apiPath else {
            print("api Path is nil")
            return
        }

        Alamofire.request(.GET, apiPath, parameters: parameters)
            .responseJSON { (response) -> Void in
                let result = response.result
                if let error = result.error {
                    completion(parkingLots: nil, error: error)
                    return
                }

                do {
                    let jsonArray = result.value as! [AnyObject]
                    let parkingLots = try MTLJSONAdapter.modelsOfClass(ParkingLot.self, fromJSONArray: jsonArray) as! [ParkingLot]
                    completion(parkingLots: parkingLots, error: nil)
                } catch let e {
                    let k = e as NSError
                    completion(parkingLots: nil, error: k)
                }
            }
    }
}


