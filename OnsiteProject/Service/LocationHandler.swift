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
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.main.async {
            directions.calculate {(response, error) in
                guard let response = response else {
                    if let error = error as? MKError {
                        print("Error: \(error)")
                    }
                    group.leave()
                    return
                }
                if response.routes.count > 0 {
                    let route = response.routes[0]
                    let (hour, min, second) = self.secondsToHoursMinutesSeconds(seconds: Int(route.expectedTravelTime))
                    if let second = second {
                        expectTime = "\(second)s"
                        if let min = min {
                            expectTime = "\(min)min \(second)s"
                            if let hour = hour {
                                expectTime = "Walking: \(hour) h \(min) min \(second) s"
                            }
                        }
                    }
                    group.leave()
                }
            }
        }
        group.wait()
        return expectTime
    }
}
//MARK: - CLLocationManagerDelegate
extension LocationHandler : CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
    }
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int?, Int?, Int?) {
        let hour = seconds / 3600 == 0 ? nil : seconds / 3600
        let min =  (seconds % 3600) / 60 == 0 ? nil : (seconds % 3600) / 60
        let second = (seconds % 3600) % 60 == 0 ? nil : (seconds % 3600) % 60
      return (hour, min, second)
    }
}
