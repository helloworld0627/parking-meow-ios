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
/** http://fortawesome.github.io/Font-Awesome/cheatsheet/ */
import FontAwesome

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var centerLocationButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var zoomInButton: UIButton!
    @IBOutlet weak var zoomOutButton: UIButton!

    // UIButton
    let defaultButtonBGColor = UIColor.blackColor()
    let defaultButtonRadius : CGFloat = 5.0
    let awesomeFontAttriute = [NSFontAttributeName : UIFont(awesomeFontOfSize: 20.0)!]

    // set as 1 mile for now
    let radius = 1600.0
    let defaultZoomLevel = 13
    var currentZoomLevel: Int = 13

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

        configCenterLocationButton()
        configSearchButton()
        configZoomInButton()
        configZoomOutButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func centerUserLocation() {
        if let location = mapView.userLocation.location {
            mapView.setCenterCoordinate(location.coordinate, animated: true, zoomLevel: defaultZoomLevel)
        }
    }

    func searchCenterLocation() {
        ParkingMeowAPIClient.sharedInstance.includeLocation(mapView.centerCoordinate)
        ParkingMeowAPIClient.sharedInstance.getParkingLots { (parkingLots, error) -> Void in
            self.onSearchResultReturned(parkingLots, error: error)
        }
    }

    func zoomInFromCenterLocation() {
        if currentZoomLevel >= 20 {
            return
        }
        print(currentZoomLevel)
        currentZoomLevel = currentZoomLevel + 1
        zoomMapView(currentZoomLevel)
    }

    func zoomOutFromCenterLocation() {
        if currentZoomLevel <= 1 {
            return
        }
        print(currentZoomLevel)
        currentZoomLevel = currentZoomLevel - 1
        zoomMapView(currentZoomLevel)
    }

    private func zoomMapView(zoomLevel: Int) {
        mapView.setCenterCoordinate(mapView.centerCoordinate, animated: true, zoomLevel: zoomLevel)
    }

    func showParkingDetailsTableViewController(sender : UIButton) {
        performSegueWithIdentifier("showDetails", sender: self)
    }


    // MARK: - Private Methods

    private func configCenterLocationButton() {
        let locatonArrow = NSString.fontAwesomeIconStringForEnum(FAIcon.FALocationArrow)
        let locAttriStr = NSAttributedString(string: locatonArrow, attributes: awesomeFontAttriute)
        centerLocationButton.setAttributedTitle(locAttriStr, forState: .Normal)
        centerLocationButton.backgroundColor = defaultButtonBGColor
        centerLocationButton.layer.cornerRadius = defaultButtonRadius
        centerLocationButton.addTarget(self, action: "centerUserLocation", forControlEvents: .TouchUpInside)
    }

    private func configSearchButton() {
        let search = NSString.fontAwesomeIconStringForEnum(FAIcon.FASearch)
        let searchAttriStr = NSAttributedString(string: search, attributes: awesomeFontAttriute)
        searchButton.setAttributedTitle(searchAttriStr, forState: .Normal)
        searchButton.backgroundColor = defaultButtonBGColor
        searchButton.layer.cornerRadius = defaultButtonRadius
        searchButton.addTarget(self, action: "searchCenterLocation", forControlEvents: .TouchUpInside)
    }

    private func configZoomInButton() {
        let zoomIn = NSString.fontAwesomeIconStringForEnum(FAIcon.FASearchPlus)
        let zoomInAttriStr = NSAttributedString(string: zoomIn, attributes: awesomeFontAttriute)
        zoomInButton.setAttributedTitle(zoomInAttriStr, forState: .Normal)
        zoomInButton.backgroundColor = defaultButtonBGColor
        zoomInButton.layer.cornerRadius = defaultButtonRadius
        zoomInButton.addTarget(self, action: "zoomInFromCenterLocation", forControlEvents: .TouchUpInside)
    }

    private func configZoomOutButton() {
        let zoomOut = NSString.fontAwesomeIconStringForEnum(FAIcon.FASearchMinus)
        let zoomOutAttriStr = NSAttributedString(string: zoomOut, attributes: awesomeFontAttriute)
        zoomOutButton.setAttributedTitle(zoomOutAttriStr, forState: .Normal)
        zoomOutButton.backgroundColor = defaultButtonBGColor
        zoomOutButton.layer.cornerRadius = defaultButtonRadius
        zoomOutButton.addTarget(self, action: "zoomOutFromCenterLocation", forControlEvents: .TouchUpInside)
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.

        if let identifier = segue.identifier {
            if "showDetails" == identifier {
                let parkingDetailsVC = segue.destinationViewController as! ParkingDetailsTableViewController
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

    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            let color = UIColor(red: 0, green: 0, blue: 255/255, alpha: 0.2)
            renderer.fillColor = color
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
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
        // clear overlays
        mapView.removeOverlays(mapView.overlays)
        let circleOverlay = MKCircle(centerCoordinate: mapView.centerCoordinate, radius: radius)
        mapView.addOverlay(circleOverlay)
        if let parkingLots = result {
            for parkingLot in parkingLots {
                mapView.addAnnotation(ParkingLotAnnotation(parkingLot: parkingLot))
            }
            currentZoomLevel = defaultZoomLevel
            mapView.setCenterCoordinate(mapView.centerCoordinate, animated: true, zoomLevel: currentZoomLevel)
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
                    currentZoomLevel = defaultZoomLevel
                    mapView.setCenterCoordinate(userLocCoord, animated: true, zoomLevel: currentZoomLevel)
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
