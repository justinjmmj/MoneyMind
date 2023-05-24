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
    @IBOutlet weak var atmTableView: UITableView!
    
    let locationManager = CLLocationManager()
    let nabSegment = 0
    let anzSegment = 1
    let cbaSegment = 2
    
    let atmCell = "atmCell"
    
    var atmSearch = "NAB ATM"
    var userLat = ""
    var userLong = ""
    
    var locationsArray:[Dictionary<String, AnyObject>] = Array()
    var atmLocations = [CLLocationCoordinate2D]()
    var atmAddress = [String]()
    
    var userLocation: CLLocationCoordinate2D?
    var pin: MKPointAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        bankSelector.selectedSegmentIndex = 0
        getATMLocations()
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
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        userLat = String(location.coordinate.latitude)
        userLong = String(location.coordinate.longitude)
        
        mapView.setRegion(region, animated: true)
        getATMLocations()
        
    }
    
    @IBAction func selectBank(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == nabSegment
        {
            atmSearch = "NAB ATM"
        }
        else if sender.selectedSegmentIndex == anzSegment
        {
            atmSearch = "ANZ ATM"
        }
        else if sender.selectedSegmentIndex == cbaSegment
        {
            atmSearch = "CBA ATM"
        }
        getATMLocations()
        atmTableView.reloadData()
    }
}


extension ATMViewController
{
    func getATMLocations()
    {
        //For testing purposes. populate with hardcoded locations
        let annotions = self.mapView.annotations
        mapView.removeAnnotations(annotions)
        
        populateAtmLocations()
        
        for atm in 0..<atmLocations.count
        {
            pin = MKPointAnnotation()
            pin!.coordinate = atmLocations[atm]
            pin!.title = atmSearch
            let place = locationsArray[atm]
            pin!.subtitle = (place["formatted_address"] as! String)
            mapView.addAnnotation(pin!)
        }
        mapView.reloadInputViews()
    }
    
    func populateAtmLocations()
    {
        var googleAPI = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(atmSearch)&location=\(userLat),\(userLong)&key=" //Add in API Key
        
        googleAPI = googleAPI.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        var urlRequest = URLRequest(url: URL(string: googleAPI)!)
        urlRequest.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response,error) in
            if error == nil
            {
                if let responseData = data {
                    let jsonDict = try? JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                    
                    if let dict = jsonDict as? Dictionary<String, AnyObject>{
                        if let results = dict["results"] as? [Dictionary<String, AnyObject>]
                        {
                            self.atmLocations.removeAll()
                            self.atmAddress.removeAll()
                            self.locationsArray.removeAll()
                            
                            for dct in results
                            {
                                let geometry = dct["geometry"] as? Dictionary<String, AnyObject>
                                let location = geometry!["location"] as? Dictionary<String, AnyObject>
                                let lat = location!["lat"] as? Double
                                let long = location!["lng"] as? Double
                                let place = dct["formatted_address"] as? String
                                let atmLoc = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
                                self.atmAddress.append(place!)
                                self.atmLocations.append(atmLoc)
                                self.locationsArray.append(dct)
                            }
                        }
                    }
                }
            }
            else
            {
                print(error!)
            }
        }
        task.resume()
        self.atmTableView.reloadData()
    }
}

extension ATMViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: atmCell)!
        if atmAddress.count != 0
        {
            let place = atmAddress[indexPath.row]
            cell.textLabel?.text = place
        }
        else
        {
            cell.textLabel?.text = "No Locations"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return atmSearch
    }
    
    
}
