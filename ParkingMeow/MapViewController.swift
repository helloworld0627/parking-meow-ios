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

        if let parkingLots = result {
            //var annotations : [MKPointAnnotation] = []
            for parkingLot in parkingLots {
                let annotation = MKPointAnnotation()
                let long = Double(parkingLot.longitude!)
                let lat = Double(parkingLot.latitude!)
                annotation.coordinate = CLLocationCoordinate2DMake(lat, long)
                annotation.title = parkingLot.webname
                mapView.addAnnotation(annotation)
            }

            mapView.showAnnotations(mapView.annotations, animated: true)
        }
    }
}

