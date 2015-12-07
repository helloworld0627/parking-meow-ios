//
//  ViewController.swift
//  ParkingMeow
//
//  Created by Chris Kwok on 11/29/15.
//  Copyright © 2015 The Meow Meow Inc. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, SearchTableViewControllerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mapView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func onSearchResultReturned(result: [ParkingLot]?, error: NSError?) {
        if let error = error {
            print(error)
            return
        }

        // clear annotatoins
        mapView.removeAnnotations(mapView.annotations)
        if let parkingLots = result {
            for parkingLot in parkingLots {
                mapView.addAnnotation(ParkingLotAnnotation(parkingLot: parkingLot))
            }
            mapView.showAnnotations(mapView.annotations, animated: true)
        }
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let _ = annotation as? MKUserLocation {
            return nil
        }

        if let annotation = annotation as? ParkingLotAnnotation {
            let identifier = "pin"
            var view : MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView{
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            }

            return view
        }

        return nil
    }
}


class ParkingLotAnnotation : NSObject, MKAnnotation {

    let parkingLot : ParkingLot
    init(parkingLot : ParkingLot) {
        self.parkingLot = parkingLot
        super.init()
    }

    var coordinate: CLLocationCoordinate2D {
        let lat = Double(parkingLot.latitude!)
        let long = Double(parkingLot.longitude!)
        return CLLocationCoordinate2DMake(lat, long)
    }

    // Title and subtitle for use by selection UI.
    var title: String? {
        return parkingLot.webname! + String(parkingLot.id!)
    }

    var subtitle: String? {
        return parkingLot.deaFacilityAddress
    }
}