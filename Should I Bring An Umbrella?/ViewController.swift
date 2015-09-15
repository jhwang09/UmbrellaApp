//
//  ViewController.swift
//  Should I Bring An Umbrella?
//
//  Created by Jerome Hwang on 9/13/15.
//  Copyright © 2015 Jerome Hwang. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var displayText: UILabel!
    
    var locationManager:CLLocationManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location!) { (placemarks, error) -> Void in
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0] as CLPlacemark
                self.displayLocationInfo(pm)
            } else {
                print("Problem with the data received from geocoder")
            }
        }
    }
    
    func displayLocationInfo(placemark: CLPlacemark?) {

        if placemark != nil {
            //stop updating location to save battery life
            locationManager.stopUpdatingLocation()
            print(placemark!.locality)
            print(placemark!.postalCode)
            print(placemark!.administrativeArea)
            print(placemark!.country)
        }
        
        Alamofire.request(.GET, "http://api.wunderground.com/api/d45e7eb8aeb1fed2/hourly/q/NJ/Jersey_City.json", parameters: nil)
            .responseJSON { _, _, json in
                let data = JSON(json.value!)
                let hourly = data["hourly_forecast"]
                
                var text = ""
                var total:Int64 = 0;
                
                for var i = 0; i < 12; i++ {
                    let hourForecast = hourly[i]
                    if hourForecast != nil {
                        let hour = hourForecast["FCTTIME"]["hour"]
                        let precip = hourForecast["pop"]
                        
                        let precipInt = precip.int64Value
                        
                        total += precipInt
                        
                        text += "\(hour) has \(precip)% chance of rain\n"
                    }
                }
                
                if total / 12 > 50 {
                    self.displayText.text = "YES, you need an umbrella!"
                } else {
                    self.displayText.text = "NO, you don't need an umbrella!"
                }

            }
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error while updating location " + error.localizedDescription)
    }
}

