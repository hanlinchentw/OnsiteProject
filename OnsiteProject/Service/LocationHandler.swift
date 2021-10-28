//
//  LocationHandler.swift
//  OnsiteProject
//
//  Created by 陳翰霖 on 2021/10/28.
//
import UIKit
import CoreLocation
import MapKit

class LocationHandler : NSObject {
    public static let shared = LocationHandler()
    
    var locationManager : CLLocationManager = {
        let lm = CLLocationManager()
        lm.desiredAccuracy = kCLLocationAccuracyBest
        return lm
    }()
    
    func enableLocationServices(){
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
}
//MARK: - CLLocationManagerDelegate
extension LocationHandler : CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
    }
}
