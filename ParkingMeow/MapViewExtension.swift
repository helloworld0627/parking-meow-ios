//
//  MapViewExtension.swift
//  ParkingMeow
//
//  Created by Chris Kwok on 12/12/2015.
//  Copyright © 2015 The Meow Meow Inc. All rights reserved.
//

import UIKit
import MapKit

/**
* Support set center coordinate with zoom level
* source: http://troybrant.net/blog/2010/01/mkmapview-and-zoom-levels-a-visual-guide/
*/
extension MKMapView {

    private var mercatorOffset: Double {
        let maxZoomLevel = 20.0
        let tilePixel = 256.0
        return tilePixel * pow(2, maxZoomLevel) //(total pixels at zoom level 20) / 2
    }

    private var mercatorRadius: Double {
        return mercatorOffset / M_PI
    }

    /* returns pixel x in scale zoom level 20 with given longitude */
    private func pixelXFromLongitude(longitude: CLLocationDegrees) -> Double {
        return round(mercatorOffset + mercatorRadius * longitude * M_PI / 180.0);
    }

    /* returns pixel y in scale zoom level 20 with given latitude */
    private func pixelYFromLatitude(latitude: CLLocationDegrees) -> Double {
        return round(mercatorOffset - mercatorRadius * log((1 + sin(latitude * M_PI / 180.0)) / (1 - sin(latitude * M_PI / 180.0))) / 2.0);
    }

    /* returns latitude in scale zoom level 20 with given pixel x */
    private func latitudeFromPixel(pixelY: Double) -> CLLocationDegrees {
        return (M_PI / 2.0 - 2.0 * atan(exp((round(pixelY) - mercatorOffset) / mercatorRadius))) * 180.0 / M_PI;
    }

    /* returns longitude in scale zoom level 20 with given pixel y */
    private func longitudeFromPixel(pixelX: Double) -> CLLocationDegrees {
        return ((round(pixelX) - mercatorOffset) / mercatorRadius) * 180.0 / M_PI;
    }
    

    func setCenterCoordinate(coordinate: CLLocationCoordinate2D, animated:Bool, zoomLevel: Int) {
        let centerPixelX = pixelXFromLongitude(coordinate.longitude)
        let centerPixelY = pixelYFromLatitude(coordinate.latitude)
        //print("\(centerPixelX) and \(centerPixelY)")
        let zoomExponent = Double(20 - zoomLevel)
        let zoomScale = pow(2, zoomExponent)
        // map size in pixel
        let size = self.bounds.size
        let scaledWidth = Double(size.width) * zoomScale
        let scaledHeight = Double(size.height) * zoomScale
        // print("\(scaledWidth) and \(scaledHeight)")
        // figure out the position of the top-left pixel
        let topLeftPixelX = centerPixelX - (scaledWidth / 2)
        let topLeftPixelY = centerPixelY - (scaledHeight / 2)
        // print("\(topLeftPixelX) and \(topLeftPixelY)")
        // find delta
        let deltaLongitude = longitudeFromPixel(topLeftPixelX + scaledWidth) - longitudeFromPixel(topLeftPixelX)
        let deltaLatitude = abs(latitudeFromPixel(topLeftPixelY + scaledHeight) - latitudeFromPixel(topLeftPixelY))
        //print("\(deltaLongitude) and \(deltaLatitude)")
        let span = MKCoordinateSpanMake(deltaLatitude, deltaLongitude)
        let region = MKCoordinateRegionMake(coordinate, span);
        setRegion(region, animated: animated)
    }
}
