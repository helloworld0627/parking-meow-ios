//
//  BaseResource.swift
//  ParkingMeow
//
//  Created by Chris Kwok on 19/12/2015.
//  Copyright © 2015 The Meow Meow Inc. All rights reserved.
//

import UIKit
import Mantle

class BaseResource : MTLModel, MTLJSONSerializing {
    var id : NSNumber?
    var createdAt : NSDate?
    var updatedAt : NSDate?

    class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return [
            "id" : "id",
            "createdAt" : "created_at",
            "updatedAt" : "updated_at"
        ]
    }

    static func createdAtJSONTransformer() -> NSValueTransformer {
        return MTLValueTransformer.transformerWithBlock { (val) -> AnyObject! in
            return NSDate()
        }
    }

    static func updatedAtJSONTransformer() -> NSValueTransformer {
        return MTLValueTransformer.transformerWithBlock { (val) -> AnyObject! in
            return NSDate()
        }
    }

    static func combineDict(dict : [NSObject : AnyObject]) -> [NSObject : AnyObject] {
        // class prefix required
        var s = BaseResource.JSONKeyPathsByPropertyKey()
        for (k,v) in dict {
            s[k] = v
        }
        return s
    }
}
