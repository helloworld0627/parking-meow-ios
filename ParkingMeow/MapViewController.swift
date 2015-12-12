//
//  ViewController.swift
//  ParkingMeow
//
//  Created by Chris Kwok on 11/29/15.
//  Copyright © 2015 The Meow Meow Inc. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var centerLocationButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!

    // does not work if defined in method
    let locationManager = CLLocationManager()
    var selectedParkingLot : ParkingLot?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // set mapViewDelegate
        mapView.delegate = self

        // location service should be enabled all the time
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
        } else {
            // should not happen
            print("CLLocationManager is not enabled.")
        }

        // add target for the button
        centerLocationButton.addTarget(self, action: "centerUserLocation", forControlEvents: .TouchUpInside)
        searchButton.addTarget(self, action: "searchCenterLocation", forControlEvents: .TouchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func centerUserLocation() {
        if let location = mapView.userLocation.location {
            mapView.centerCoordinate = location.coordinate
        }
    }

    func searchCenterLocation() {
        ParkingMeowAPIClient.sharedInstance.includeLocation(mapView.centerCoordinate)
        ParkingMeowAPIClient.sharedInstance.getParkingLots { (parkingLots, error) -> Void in
            self.onSearchResultReturned(parkingLots, error: error)
        }
    }

    func showParkingDetailsTableViewController(sender : UIButton) {
        performSegueWithIdentifier("showDetails", sender: self)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.

        if let identifier = segue.identifier {
            if "showDetails" == identifier {
                let vc = segue.destinationViewController
                let parkingDetailsVC = vc as! ParkingDetailsTableViewController
                parkingDetailsVC.parkingLot = selectedParkingLot
            }
        }
    }
}

extension MapViewController : MKMapViewDelegate {
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
                let button = UIButton(type: .DetailDisclosure)
                button.addTarget(self, action:"showParkingDetailsTableViewController:", forControlEvents: UIControlEvents.TouchUpInside)
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.rightCalloutAccessoryView = button
            }

            return view
        }

        return nil
    }

    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let annotation = view.annotation as? ParkingLotAnnotation {
            self.selectedParkingLot = annotation.parkingLot
        }
    }
}

extension MapViewController : SearchTableViewControllerDelegate {
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
            //mapView.showAnnotations(mapView.annotations, animated: true)
        }
    }

    func currentLocationCoordinate() -> CLLocationCoordinate2D? {
        return self.mapView.centerCoordinate
    }
}

extension MapViewController : CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            manager.startUpdatingLocation()
            mapView.showsUserLocation = (status == .AuthorizedWhenInUse)
        } else {
            print("CLAuthorizationStatus is \(status).")
        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {
            let locCoord = locations[0].coordinate
            let userLocCoord = mapView.userLocation.coordinate
            if userLocCoord.latitude == locCoord.latitude
                && userLocCoord.longitude == locCoord.longitude {
                    let region = MKCoordinateRegionMakeWithDistance(userLocCoord, 1000, 1000)
                    mapView.setRegion(region, animated: true)
                    // avoid recursively calling this after map center is updated
                    manager.stopUpdatingLocation()
            }
        }
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
        let nameVal = (parkingLot.webname != nil) ? parkingLot.webname : (parkingLot.facName != nil) ? parkingLot.facName : parkingLot.opName
        return nameVal
    }

    var subtitle: String? {
        return parkingLot.deaFacilityAddress
    }
}
