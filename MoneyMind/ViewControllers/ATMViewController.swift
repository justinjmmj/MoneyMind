//
//  ATMViewController.swift
//  MoneyMind
//
//  Created by Justin Justiniano  on 18/5/21.
//

import UIKit
import MapKit
import CoreLocation

class ATMViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var bankSelector: UISegmentedControl!
    
    let locationManager = CLLocationManager()
    let nabSegment = 0
    let anzSegment = 1
    let cbaSegment = 2
   
    var nabURL = "https://sandbox.api.nab/v2/locations?locationType=atm&v=1"
    
    var atmLocations = [CLLocationCoordinate2D]() // ATMLocations will be fetched from the API's of specific banks
    var nabATMLoc = [CLLocationCoordinate2D]()
    var anzATMLoc = [CLLocationCoordinate2D]()
    var cbaATMLoc = [CLLocationCoordinate2D]()
    
    
    var userLocation: CLLocationCoordinate2D?
    var pin: MKPointAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        
        //For Testing Purposes
        let monashClayton = CLLocationCoordinate2D(latitude: -37.9108516, longitude: 145.1355282)
        let theatreLG02 = CLLocationCoordinate2D(latitude: -37.9095225, longitude: 145.1354168)
        let atm1 =  CLLocationCoordinate2D(latitude: -37.9098516, longitude: 145.1335282)
        let atm2 =  CLLocationCoordinate2D(latitude: -37.9098516, longitude: 145.1362382)
        let atm3 =  CLLocationCoordinate2D(latitude: -37.9098516, longitude: 145.1312382)
        let atm4 =  CLLocationCoordinate2D(latitude: -37.9088516, longitude: 145.1295282)
        
        
        nabATMLoc.append(monashClayton)
        nabATMLoc.append(theatreLG02)
        anzATMLoc.append(atm1)
        anzATMLoc.append(atm2)
        cbaATMLoc.append(atm3)
        cbaATMLoc.append(atm4)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let status = locationManager.authorizationStatus
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        else
        {
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
            userLocation = mapView.userLocation.coordinate
            print(userLocation!)
        }
    }
    
    @IBAction func selectBank(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == nabSegment
        {
            print("NAB selected")
        }
        else if sender.selectedSegmentIndex == anzSegment
        {
            print("ANZ selected")
        }
        else if sender.selectedSegmentIndex == cbaSegment
        {
            print("CBA selected")
        }
        getATMLocations()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first
        {
            manager.stopUpdatingLocation()
            render(location)
        }
    }
    
    func render(_ location: CLLocation)
    {
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        mapView.setRegion(region, animated: true)
        getATMLocations()
        
    }
    
    func getATMLocations()
    {
        //For testing purposes. populate with hardcoded locations
        let annotions = self.mapView.annotations
        mapView.removeAnnotations(annotions)
        
        if (bankSelector.selectedSegmentIndex == nabSegment)
        {
            for atm in nabATMLoc
            {
                pin = MKPointAnnotation()
                pin!.coordinate = atm
                mapView.addAnnotation(pin!)
                //mapView.reloadInputViews()
            }
        }
        else if (bankSelector.selectedSegmentIndex == anzSegment)
        {
            for atm in anzATMLoc
            {
                pin = MKPointAnnotation()
                pin!.coordinate = atm
                mapView.addAnnotation(pin!)
                //mapView.reloadInputViews()
            }
        }
        else if (bankSelector.selectedSegmentIndex == cbaSegment)
        {
            for atm in cbaATMLoc
            {
                pin = MKPointAnnotation()
                pin!.coordinate = atm
                mapView.addAnnotation(pin!)
                //mapView.reloadInputViews()
            }
        }
        
    }
    

}
