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
    private let defaultButtonBGColor = UIColor.blackColor()
    private let defaultButtonRadius : CGFloat = 5.0
    private let awesomeFontAttriute = [NSFontAttributeName : UIFont(awesomeFontOfSize: 20.0)!]

    // set as 1 mile for now
    private let radius = 1600.0
    private let defaultZoomLevel = 13
    private var currentZoomLevel: Int = 13

    // does not work if defined in method
    private var locationManager: CLLocationManager?
    private var selectedParkingLot: ParkingLot?

    //
    var predefinedSearchCriteria: ParkingSearchCriteria?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // set mapViewDelegate
        mapView.delegate = self

        // config button icons
        configAwesomeIconButton(centerLocationButton, icon: FAIcon.FALocationArrow)
        configAwesomeIconButton(searchButton, icon: FAIcon.FASearch)
        configAwesomeIconButton(zoomInButton, icon: FAIcon.FASearchPlus)
        configAwesomeIconButton(zoomOutButton, icon: FAIcon.FASearchMinus)
        // add actions to buttons
        centerLocationButton.addTarget(self, action: "centerUserLocation", forControlEvents: .TouchUpInside)
        searchButton.addTarget(self, action: "searchCenterLocation", forControlEvents: .TouchUpInside)
        zoomInButton.addTarget(self, action: "zoomInFromCenterLocation", forControlEvents: .TouchUpInside)
        zoomOutButton.addTarget(self, action: "zoomOutFromCenterLocation", forControlEvents: .TouchUpInside)

        /* handle predefinedSearchCriteria from master view, if any*/
        if let criteria = predefinedSearchCriteria where criteria.coordinate != nil {
            performSearch(criteria)
        }

        // prepare location
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .Restricted || authStatus == .Denied {
            print("TODO pop alert box ask user to enable")
            return
        } else {
            // .AuthorizedWhenInUse or .AuthorizedAlways or .NotDetermined
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            if authStatus == .NotDetermined {
                // only work for NotDetermined status. see doc
                locationManager?.requestWhenInUseAuthorization()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Button actions

    func centerUserLocation() {
        if let location = mapView.userLocation.location {
            mapView.setCenterCoordinate(location.coordinate, animated: false, zoomLevel: defaultZoomLevel)
        } else {
            let alertAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            let alertController = UIAlertController(title: "Location Access Failed", message: nil, preferredStyle: .Alert)
            alertController.addAction(alertAction)
            presentViewController(alertController, animated: false, completion: nil)
        }
    }

    func searchCenterLocation() {
        var searchCriteria: ParkingSearchCriteria? = predefinedSearchCriteria
        if predefinedSearchCriteria == nil {
            searchCriteria = ParkingSearchCriteria()
        }
        searchCriteria?.coordinate = mapView.centerCoordinate
        performSearch(searchCriteria!)
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

    func showParkingDetailsTableViewController(sender : UIButton) {
        performSegueWithIdentifier("showDetails", sender: self)
    }

    private func zoomMapView(zoomLevel: Int) {
        mapView.setCenterCoordinate(mapView.centerCoordinate, animated: false, zoomLevel: zoomLevel)
    }


    // MARK: - Private Methods

    private func configAwesomeIconButton(button: UIButton, icon: FAIcon) {
        let iconString = NSString.fontAwesomeIconStringForEnum(icon)
        let locAttriStr = NSAttributedString(string: iconString, attributes: awesomeFontAttriute)
        button.setAttributedTitle(locAttriStr, forState: .Normal)
        button.backgroundColor = defaultButtonBGColor
        button.layer.cornerRadius = defaultButtonRadius
    }

    private func performSearch(parkingSearchCriteria: ParkingSearchCriteria) {

        let spinnerContainer = UIView(frame: mapView.frame)
        spinnerContainer.backgroundColor = UIColor.grayColor()
        spinnerContainer.alpha = 0.5
        view.addSubview(spinnerContainer)

        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        let center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds))
        activityIndicator.center = center
        spinnerContainer.addSubview(activityIndicator)
        activityIndicator.startAnimating()

        ParkingMeowAPIClient.sharedInstance.getParkingLots(parkingSearchCriteria.requestParameters) {
            (parkingLots, error) -> Void in

            defer {
                spinnerContainer.removeFromSuperview()
            }

            let coordinate = parkingSearchCriteria.coordinate!
            let mapView = self.mapView
            // clean up UI
            mapView.removeAnnotations(mapView.annotations)
            mapView.removeOverlays(mapView.overlays)
            // add circle overlay
            mapView.addOverlay(MKCircle(centerCoordinate: coordinate, radius: self.radius))

            if let error = error {
                print(error)
                return
            }

            self.currentZoomLevel = self.defaultZoomLevel
            mapView.setCenterCoordinate(coordinate, animated: false, zoomLevel: self.currentZoomLevel)
            if let parkingLots = parkingLots where parkingLots.count > 0 {
                for parkingLot in parkingLots {
                    mapView.addAnnotation(ParkingLotAnnotation(parkingLot: parkingLot))
                }
            } else {
                let alertAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                let alertController = UIAlertController(title: "No Results", message: "Please try another location and/or search criteria.", preferredStyle: .Alert)
                alertController.addAction(alertAction)
                self.presentViewController(alertController, animated: false, completion: nil)
            }
        }
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


// MARK: - CoordinateDelegate

extension MapViewController: CoordinateDelegate {
    var coordinate: CLLocationCoordinate2D {
        return mapView.centerCoordinate
    }
}


// MARK: - MKMapViewDelegate

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


// MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            mapView.showsUserLocation = true
            // ensure locaton service enabled; otherwise error occurs on delegate
            if CLLocationManager.locationServicesEnabled() {
                manager.startUpdatingLocation()
            }
        } else {
            print("CLAuthorizationStatus is \(status.rawValue).")
        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {
            let locCoord = locations[0].coordinate
            let userLocCoord = mapView.userLocation.coordinate
            // if updateLocation is current user location
            if userLocCoord.latitude == locCoord.latitude && userLocCoord.longitude == locCoord.longitude {
                // avoid recursively calling this
                manager.stopUpdatingLocation()
                if predefinedSearchCriteria == nil {
                    currentZoomLevel = defaultZoomLevel
                    mapView.setCenterCoordinate(userLocCoord, animated: false, zoomLevel: currentZoomLevel)
                }
            }
        }
    }
}


// MARK: - MKAnnotation

class ParkingLotAnnotation: NSObject, MKAnnotation {

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
