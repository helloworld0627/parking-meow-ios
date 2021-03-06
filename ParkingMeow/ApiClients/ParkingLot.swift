//
//  ParkingLot.swift
//  ParkingMeow
//
//  Created by Chris Kwok on 19/12/2015.
//  Copyright © 2015 The Meow Meow Inc. All rights reserved.
//

import UIKit
import Mantle

class ParkingLot: BaseResource {

    var objectId: NSNumber?
    var buslicLocationId: NSNumber?
    var deaFacilityAddress: String?
    var deaStalls: NSNumber?
    var facName: String?
    var disabled: NSNumber?
    var opName: String?
    var opPhone: String?
    var opPhone2: String?
    var opWeb: String?
    //var payment_type: null
    // var other_type: enum??
    var webname: String?
    var regionId: NSNumber?
    //var outofserv_type: enum,
    var vacant: NSNumber?
    var signId: String?
    var longitude: NSNumber?
    var latitude: NSNumber?
    // collection
    var parkingRates: [ParkingRate]?
    var parkingBusinessHours : [ParkingBusinessHour]?


    override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        let dict = [
            "objectId" : "objectid",
            "buslicLocationId" : "buslic_location_id",
            "deaFacilityAddress" : "dea_facility_address",
            "deaStalls" : "dea_stalls",
            "facName" : "fac_name",
            "disabled" : "disabled",
            "opName" : "op_name",
            "opPhone" : "op_phone",
            "opPhone2" : "op_phone2",
            "opWeb" : "op_web",
            //"payment_type" : "payment_type",
            //"other_type" : "other_type",
            "webname" : "webname",
            "regionId" :"regionid",
            //"outofserv_type" :  "outofserv_type",
            "vacant" : "vacant",
            "signId" : "signid",
            "longitude" : "longtitude",
            "latitude" : "latitude",
            "parkingRates" : "parkingRates",
            "parkingBusinessHours" : "parkingBusinessHours",
        ]

        return combineDict(dict)
    }

    static func latitudeJSONTransformer() -> NSValueTransformer {
        return MTLValueTransformer.reversibleTransformerWithBlock({ (val) -> AnyObject! in
            if val != nil {
                let strVal = val as! String
                return Double(strVal)
            }
            return 0.0
        })
    }

    static func longitudeJSONTransformer() -> NSValueTransformer {
        return MTLValueTransformer.reversibleTransformerWithBlock({ (val) -> AnyObject! in
            if val != nil {
                let strVal = val as! String
                return Double(strVal)
            }
            return 0.0
        })
    }

    static func parkingRatesJSONTransformer() -> NSValueTransformer {
        return MTLJSONAdapter.arrayTransformerWithModelClass(ParkingRate.self)
    }

    static func parkingBusinessHoursJSONTransformer() -> NSValueTransformer {
        return MTLJSONAdapter.arrayTransformerWithModelClass(ParkingBusinessHour.self)
    }
}


class ParkingRate: BaseResource {
    enum RateType : String {
        case OneHour = "rte_1hr"
        case TwoHour = "rte_2hr"
        case ThreeHour = "rte_3hr"
        case AllDay = "rte_allday"
    }

    var price : NSNumber?
    var parkingRateDescription : String?

    private(set) var rateTypeStr : String?
    lazy var rateType : RateType? = {
        let str = self.rateTypeStr
        return RateType(rawValue: str!)
    }()

    override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        let dict = [
            "rateTypeStr" : "rate_type",
            "price" : "price",
            "parkingRateDescription" : "description"
        ]
        return combineDict(dict)
    }

    static func priceJSONTransformer() -> NSValueTransformer {
        return MTLValueTransformer.reversibleTransformerWithBlock({ (val) -> AnyObject! in
            if val != nil {
                let strVal = val as! String
                return Double(strVal)
            }
            return 0.0
        })
    }
}


class ParkingBusinessHour: BaseResource {
    enum HourType : String {
        case Sun = "hrs_sun"
        case Sat = "hrs_sat"
        case MonFri = "hrs_monfri"
    }

    private(set) var hourTypeStr : String?
    lazy var hourType : HourType? = {
        let str = self.hourTypeStr
        return HourType(rawValue: str!)
    }()
    var fromTo : String?

    override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        let dict = [
            "hourTypeStr" : "hour_type",
            "fromTo" : "from_to"
        ]
        return combineDict(dict)
    }
}
