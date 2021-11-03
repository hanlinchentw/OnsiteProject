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
    func calculateTravelingTime(to destination: CLLocationCoordinate2D) -> String {
        guard let userLocation = locationManager.location?.coordinate else { return String()}
        var expectTime = String()
        let request = MKDirections.Request()
        let sourceMark = MKPlacemark(coordinate: userLocation)
        let destinationMark = MKPlacemark(coordinate: destination)
        request.source = MKMapItem(placemark: sourceMark)
        request.destination = MKMapItem(placemark: destinationMark)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        let directions = MKDirections(request: request)
        directions.calculate {(response, error) in
            guard let response = response else {
                if let error = error as? MKError {
                    print("Error: \(error)")
                }
                return
            }
            if response.routes.count > 0 {
                let route = response.routes[0]
                print("Walking time:", userLocation," to ", destination, "\(route.expectedTravelTime/60)")
                expectTime = "\(route.expectedTravelTime/60)"
            }
        }
        return expectTime
    }
}
//MARK: - CLLocationManagerDelegate
extension LocationHandler : CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
    }
}
