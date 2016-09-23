//
//  ViewController.swift
//  Clima
//
//  Created by Shashank Ranjan on 8/28/16.
//  Copyright © 2016 Shashank Ranjan. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate {
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var imageLabel: UIImageView!
    @IBOutlet weak var placeLabel: UILabel!
    
    var manager = CLLocationManager()
    var placemark = CLPlacemark()
    var geocoder = CLGeocoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
        manager.requestAlwaysAuthorization()
       }// viewdidLoad closed
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
       {
         let saveQueue = dispatch_queue_create("saveQueue", DISPATCH_QUEUE_CONCURRENT)
        let location = locations[0]
        geocoder.reverseGeocodeLocation(location) { (placemark, error) in
            if placemark?.count > 0
            {
                let place = placemark![0]
                 print(place.locality)
                dispatch_async(dispatch_get_main_queue())
                {
                self.placeLabel.text = place.locality
                }
            }
        }
        dispatch_async(saveQueue){
        let urlString = "https://api.darksky.net/forecast/b793b61eb06b5ef411e11b85a1799c91/\(location.coordinate.latitude),\(location.coordinate.longitude)"
        let url:NSURL = NSURL(string: urlString)!
        let config:NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session:NSURLSession = NSURLSession(configuration: config)
        let request:NSURLRequest = NSURLRequest(URL: url)
        let task = session.dataTaskWithRequest(request){ (data, responce, error) in
            do
            {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? [String: AnyObject]
              if let item = json!["currently"]!["temperature"] as? Int
              {
                // changing farenhite to celsius
                let temp = Double(item - 32)/1.8000
                let gettemp = Int(temp)
                dispatch_async(dispatch_get_main_queue())
                {
                self.tempLabel.text = "\(gettemp)ºC"
                print(self.tempLabel.text)
              }
             }
            }
            catch
            {
                print(error)
            }
            
        }// task closed
        task.resume()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

