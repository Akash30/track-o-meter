//
//  MeterViewController.swift
//  PocketMeter
//
//  Created by Akash Subramanian on 7/16/15.
//  Copyright (c) 2015 Akash Subramanian. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MeterViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate
{
    let manager = AppDelegate.Location.Manager
    var locations = [CLLocation]()
    var startLocation: CLLocation!
    var endLocation: CLLocation!
    var temp: Double = 0.0
    var runMeter:Bool?
    var continueMeter: Bool?
    var myLocations = [CLLocation]()
    let defaults = NSUserDefaults.standardUserDefaults()
    var meterType: String = ""
    var meterHasNotBeenStarted = true
    var home: CLCircularRegion!
    var isStandardMapType = false
    var isSatelliteMapType = false
    var isHybridMapType = false
    var destination: MKMapItem!
    var mapItems = [MKMapItem]()
    var timeLastUpdatedLocation: NSDate!
    
    
    @IBOutlet weak var map: MKMapView!
    
    var incrementByTwoAfter800Meters = false
    var valueToIncrement = 1.9
    @IBOutlet weak var fareLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isStandardMapType = defaults.valueForKey("standard") as! Bool
        isSatelliteMapType = defaults.valueForKey("satellite") as! Bool
        isHybridMapType = defaults.valueForKey("hybrid") as! Bool
        println("\(isStandardMapType)")
        
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        regionMonitoring()
        
        
        
        
        if runMeter == true {
            fare = 0.0
            traveledDistance = 0.0
            meterHasNotBeenStarted = true
            manager.requestStateForRegion(home)
            
            
            if fare == 0.0 {
                switch meterType {
                case "Mumbai Auto Rikshaw": fare = Constants.MumbaiStartingFare
                case "Dubai Taxi":
                    if startNightTimeFare() {
                        fare = Constants.DubaiTaxiNightStartingFare
                    }
                    else {
                        fare = Constants.DubaiTaxiDayStartingFare
                        
                    }
                
                    
                default: println("start wrong meterType")
                
                }
                

            }
            
            if let location = destination {
                addAnnotaion(destination)
                getDirections()
            }
            //meterHasNotBeenStarted = false
            start()
            
            
            
        }
        
        if runMeter == false {
           stop()
        }
        /*
        if continueMeter == true {
            continueMeter = false
            if let someFare = defaults.valueForKey("fare") as? Double {
                fare = someFare
                defaults.removeObjectForKey("fare")
            }
            if let someDistance = defaults.valueForKey("traveledDistance") as? Double {
                traveledDistance = someDistance
                defaults.removeObjectForKey("traveledDistance")
            }
        } */
        
        map.delegate = self
        if isStandardMapType == true {
            println("here1")
            map.mapType = MKMapType.Standard
        } else if isSatelliteMapType == true { println("here2")
            map.mapType = MKMapType.Satellite
        } else if isHybridMapType == true { println("here3")
            map.mapType = MKMapType.Hybrid
        } else { println("here4")
            map.mapType = MKMapType.Standard
        }
        
        map.showsUserLocation = true
    }
    
    
    
    func addAnnotaion (item: MKMapItem) {
        var annotation = MKPointAnnotation()
        annotation.coordinate = item.placemark.coordinate
        annotation.title = item.name
        self.map.addAnnotation(annotation)
    }
    
    
    func getDirections() {
        if destination != nil {
            let request = MKDirectionsRequest()
            request.setSource(MKMapItem.mapItemForCurrentLocation())
            request.setDestination(destination!)
            request.requestsAlternateRoutes = false
            
            let directions = MKDirections(request: request)
            
            directions.calculateDirectionsWithCompletionHandler({(response:
                MKDirectionsResponse!, error: NSError!) in
                
                if error != nil {
                    println("Error getting directions")
                } else {
                    self.showRoute(response)
                }
                
            })

        }
    }
    
    
    func showRoute(response: MKDirectionsResponse) {
        
        for route in response.routes as! [MKRoute] {
            
            map.addOverlay(route.polyline,
                level: MKOverlayLevel.AboveRoads)
            
            for step in route.steps {
                println(step.instructions)
            }
        }
        let userLocation = map.userLocation
        let region = MKCoordinateRegionMakeWithDistance(
            userLocation.location.coordinate, 2000, 2000)
        
        map.setRegion(region, animated: true)
    }
    
    
    
   /*
   
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        println("YO")
        
        if meterHasNotBeenStarted {
            traveledDistance = 0.0
            fare = 0.0
        } else {
            if let someFare = defaults.valueForKey("fare") as? Double {
                fare = someFare
                
            }
            if let someDistance = defaults.valueForKey("traveledDistance") as? Double {
                traveledDistance = someDistance
            }
            
        }

    }
 */
    
    func startNightTimeFare() -> Bool {
        let currentDate = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitMonth | .CalendarUnitYear | .CalendarUnitDay, fromDate: currentDate)
        let hour = components.hour
        let minutes = components.minute
        
        let month = components.month
        let year = components.year
        let day = components.day
        
        if (hour == 22 && minutes >= 30) || (hour > 22) || (hour < 6) || (hour == 6 && minutes == 0) {
            return true
        }
        
        
//        let dateString = "10:30 PM"
//        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "hh:mm"
//        dateFormatter.timeZone = NSTimeZone.localTimeZone()
//        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
//        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
//        let dateValue = dateFormatter.dateFromString(dateString) as NSDate!
//        if dateValue.compare(currentDate) != NSComparisonResult.OrderedAscending {
//            return true
//        }
        
        
        return false
    }
    
    
    
    
    
    
    func regionMonitoring() {
        
        
        home = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 25.060833, longitude: 55.188333), radius: 200, identifier: "Home")
        manager.startMonitoringForRegion(home)
        //manager.requestStateForRegion(home)
        
//        let dubaiAirport = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 25.2528, longitude: 55.3644), radius: 200, identifier: "Home")
//        manager.startMonitoringForRegion(dubaiAirport)
        
    }
    
    func start() {
        traveledDistance = 0
       
        manager.desiredAccuracy = Constants.LocationAccuracy
        manager.distanceFilter = Constants.DistanceFilter
        startLocation = nil
        manager.startUpdatingLocation()
    }
    
    func stop() {
        manager.stopUpdatingLocation()
        if let someFare = defaults.valueForKey("fare") as? Double {
            fare = someFare
            
        }
        if let someDistance = defaults.valueForKey("traveledDistance") as? Double {
            traveledDistance = someDistance
        }

    }
    
    
    
    var fare:Double? {
        get {
            if let currentFare = fareLabel.text {
                return NSNumberFormatter().numberFromString(currentFare)!.doubleValue
            }
            return 0.0
        }
        
        set {
            if let newFare = newValue {
                fareLabel.text = "\(newFare)"
                defaults.setValue(newFare, forKey: "fare")
            }
            
        }
    }
       
    var traveledDistance: Double? {
        get {
            if let currentDistance = distanceLabel.text {
                return NSNumberFormatter().numberFromString(currentDistance)!.doubleValue
            }
            return 0.0
        }
        
        set {
            if let newDistance = newValue {
                distanceLabel.text = "\(newValue!)"
                defaults.setValue(newDistance, forKey: "traveledDistance")
            }
            
        }
    }
    
    struct Constants {
        static let LocationAccuracy = kCLLocationAccuracyBest
        static let DistanceFilter = kCLDistanceFilterNone
        static let MumbaiStartingFare = 17.0
        static let Scale = Double(1000)
        static let DubaiTaxiAirportStartingFare = 20.0
        static let DubaiTaxiDayStartingFare = 3.0
        static let DubaiTaxiNightStartingFare = 3.5
        
        
        
    }
    
    
    
    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
        println(meterType)
        switch meterType {
            case "Dubai Taxi":
                if meterHasNotBeenStarted == true {
                    if state == CLRegionState.Inside {
                        NSLog("Inside region")
                        fare = Constants.DubaiTaxiAirportStartingFare
                    }
                    
//                    if state == CLRegionState.Outside {
//                        NSLog("Outide region")
//                        fare = 0.0
//                    }
                    
                    
                    
                }
                if runMeter == true {
                    meterHasNotBeenStarted = false
            }
            
        default: break

            
        }
        
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        NSLog("Entering region")
        
        
        
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        NSLog("Exit region")
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        NSLog("\(error)")
    }
    
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        map.showsUserLocation = (status == .AuthorizedAlways)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        myLocations.append(locations[0] as! CLLocation)
        if startLocation == nil {
            startLocation = locations.first as? CLLocation
        } else {
            let distance = startLocation.distanceFromLocation(locations.last as! CLLocation)
            let lastDistance = endLocation.distanceFromLocation(locations.last as! CLLocation)
            temp += lastDistance
            //let newDistance = traveledDistance! + roundedDistance(temp)
            //computeDistance(newDistance)
            let roundedTemp = roundedDistance(temp)
            //traveledDistance! += roundedTemp
            computeDistance(roundedTemp)
            
            
//            println( "\(startLocation)")
//            println( "\(locations.last!)")
//            println("FULL DISTANCE: \(traveledDistance)")
//            println("STRAIGHT DISTANCE: \(distance)")
        }
        endLocation = locations.last as! CLLocation
        
        computeWaitingCharge()
        
        
        let spanX = 0.007
        let spanY = 0.007
        var newRegion = MKCoordinateRegion(center: map.userLocation.coordinate, span: MKCoordinateSpanMake(spanX, spanY))
        map.setRegion(newRegion, animated: true)
        
        if (myLocations.count > 1){
            var sourceIndex = myLocations.count - 1
            var destinationIndex = myLocations.count - 2
            
            let c1 = myLocations[sourceIndex].coordinate
            let c2 = myLocations[destinationIndex].coordinate
            var a = [c1, c2]
            var polyline = MKPolyline(coordinates: &a, count: a.count)
            map.addOverlay(polyline)
            
        }
    }
    
    
    
    func computeWaitingCharge() {
        let currentTime = NSDate()
        if let lastTime = timeLastUpdatedLocation {
            let elapsedTime = currentTime.timeIntervalSinceDate(timeLastUpdatedLocation)
            if elapsedTime >= 60 {
                let waitingChargeMultiplier = floor(elapsedTime / 60)
        
                switch meterType {
                case "Mumbai Auto Rikshaw" : fare! += 1.20 * waitingChargeMultiplier
                case "Dubai Taxi" : fare! += 0.5 * waitingChargeMultiplier
                default : break
                }
            }
        } else {
            timeLastUpdatedLocation = currentTime
        }
        
        
    }
    
    func computeDistance(distance: Double) {
        switch meterType {
        case "Mumbai Auto Rikshaw":
            //if distance > traveledDistance! {
            if distance > 0.0 {
            temp = 0.0
                
                traveledDistance! += distance
                computeFare(traveledDistance!)
            }
            
        case "Dubai Taxi":
            if distance >= 0.625 {
                temp = 0.0
                
                traveledDistance! += distance
                computeFare(traveledDistance!)
                
            }
            
        default: println("computeDistance function  - wrong meterType")

        
        }
    }
    
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        
        if overlay is MKPolyline {
            var polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blueColor()
            polylineRenderer.lineWidth = 3
            
            return polylineRenderer
        }
        
        return nil
    }
    
    
    func roundedDistance(distance: Double) -> Double {
        let distanceInKilometers = distance / Constants.Scale
        var roundedNumber: Double = 0.0
        switch meterType {
            case "Mumbai Auto Rikshaw": roundedNumber = floor(distanceInKilometers * 10) / 10
            case "Dubai Taxi": roundedNumber = floor(distanceInKilometers * 1000) / 1000
        default: println("rounded distance function - wrong meter type")
        }
        
        return roundedNumber
    }
    
    func computeFare(distance: Double) {
        switch meterType {
        case "Mumbai Auto Rikshaw": computeMumbaiFare(distance)
        case "Dubai Taxi": computeDubaiTaxiFare(distance)
        default: println("computeFare - wrong meterType")
        }
     
    }
    
    
    func computeDubaiTaxiFare (distance: Double) {
        fare! += 1.0
    }
    
    func computeMumbaiFare(distance: Double) {
        if distance > 1.5 {
            fare! += 1
            
            if incrementByTwoAfter800Meters && (distance >=  valueToIncrement && distance < (valueToIncrement + 0.1)){
                fare! += 1
                incrementByTwoAfter800Meters = !incrementByTwoAfter800Meters
                valueToIncrement += 0.7
            }
            
            if !incrementByTwoAfter800Meters && (distance >=  valueToIncrement && distance < (valueToIncrement + 0.1)){
                fare! += 1
                incrementByTwoAfter800Meters = !incrementByTwoAfter800Meters
                valueToIncrement += 0.8
            }
        }
    }
    
    
    
    
    
}
